/**
 * Inputs
 * - client_id, client_secret, tenant_id
 * - organizer_email       // May be @peninsula-*.com, while AAD UPN is @employsure.*.
 * - event_start (UTC ISO) // e.g., "2026-03-02T05:00:00Z"
 * - event_end   (UTC ISO) // optional
 * - calendly_unique_id    // optional, for event.location.uniqueId match
 * - retries, delay_ms     // OM lookup retry config (default 3, 5000)
 * - cal_retries, cal_delay_ms // calendarView retry config (default 3, 5000)
 */
const clientId = (inputData.client_id || '').trim();
const clientSecret = (inputData.client_secret || '').trim();
const tenantId = (inputData.tenant_id || '').trim();
const organizerEmail = (inputData.organizer_email || '').trim();
const eventStart = (inputData.event_start || '').trim();
const eventEnd = (inputData.event_end || '').trim();
const calendlyUnique = (inputData.calendly_unique_id || '').trim();

const OM_MAX_RETRIES = Number.isFinite(+inputData.retries) ? Math.max(0, +inputData.retries) : 3;
const OM_DELAY_MS = Number.isFinite(+inputData.delay_ms) ? Math.max(0, +inputData.delay_ms) : 5000;
const CAL_MAX_RETRIES = Number.isFinite(+inputData.cal_retries) ? Math.max(0, +inputData.cal_retries) : 3;
const CAL_DELAY_MS = Number.isFinite(+inputData.cal_delay_ms) ? Math.max(0, +inputData.cal_delay_ms) : 5000;

if (!clientId || !clientSecret || !tenantId) {
  return {
    success: false,
    stage: 'token',
    error: 'Missing Azure credentials',
    clientId_present: !!clientId,
    clientSecret_present: !!clientSecret,
    tenantId_present: !!tenantId
  };
}

// Helpers
const padMinutes = (iso, delta) => {
  const d = new Date(iso);
  return new Date(d.getTime() + delta * 60000).toISOString().replace(/\.\d{3}Z$/, 'Z');
};
// OData string literal: wrap in single quotes; double any embedded single quotes
const odataString = (s) => `'${String(s).replace(/'/g, "''")}'`;
// Safe JSON
const safeJson = async (res) => {
  const t = await res.text();
  try { return JSON.parse(t); } catch { return { raw: t }; }
};
const delay = (ms) => new Promise(r => setTimeout(r, ms));

/**
 * Resolve the user by an arbitrary email.
 * Strategy: UPN -> mail -> proxyAddresses(any) -> otherMails(any)
 * Notes:
 *  - proxyAddresses/any and otherMails/any are advanced queries => need ConsistencyLevel: eventual + $count=true
 *  - return { id, userPrincipalName } if found, else null
 */
async function resolveUserByEmail(email, token) {
  // 1) Direct UPN path (works if the email equals the UPN)
  {
    const r = await fetch(
      `https://graph.microsoft.com/v1.0/users/${encodeURIComponent(email)}?$select=id,userPrincipalName`,
      { headers: { Authorization: `Bearer ${token}` } }
    );
    if (r.ok) {
      const j = await safeJson(r);
      if (j?.id) return { id: j.id, userPrincipalName: j.userPrincipalName };
    }
  }

  // 2) Primary SMTP mail eq 'email'  (simple filter)
  {
    const url =
      `https://graph.microsoft.com/v1.0/users?$filter=mail eq ${odataString(email)}` +
      `&$select=id,userPrincipalName`;
    const r = await fetch(url, { headers: { Authorization: `Bearer ${token}` } });
    const j = await safeJson(r);
    if (r.ok && Array.isArray(j.value) && j.value.length === 1) {
      return { id: j.value[0].id, userPrincipalName: j.value[0].userPrincipalName };
    }
    if (r.ok && Array.isArray(j.value) && j.value.length > 1) {
      // If multiple, pick the one with UPN ending on known corp domains
      const pick = j.value.find(u => /@employsure\.(com\.au|co\.nz)$/i.test(u.userPrincipalName)) || j.value[0];
      return { id: pick.id, userPrincipalName: pick.userPrincipalName };
    }
  }

  // 3) proxyAddresses/any(p:p eq 'SMTP:email')  (advanced query)
  {
    const url =
      `https://graph.microsoft.com/v1.0/users` +
      `?$count=true&$filter=proxyAddresses/any(p:p eq ${odataString('SMTP:' + email)})` +
      `&$select=id,userPrincipalName`;
    const r = await fetch(url, {
      headers: {
        Authorization: `Bearer ${token}`,
        'ConsistencyLevel': 'eventual'
      }
    });
    const j = await safeJson(r);
    if (r.ok && Array.isArray(j.value) && j.value.length > 0) {
      const pick = j.value.find(u => /@employsure\.(com\.au|co\.nz)$/i.test(u.userPrincipalName)) || j.value[0];
      return { id: pick.id, userPrincipalName: pick.userPrincipalName };
    }
  }

  // 4) otherMails/any(c:c eq 'email')  (advanced query)
  {
    const url =
      `https://graph.microsoft.com/v1.0/users` +
      `?$count=true&$filter=otherMails/any(c:c eq ${odataString(email)})` +
      `&$select=id,userPrincipalName`;
    const r = await fetch(url, {
      headers: {
        Authorization: `Bearer ${token}`,
        'ConsistencyLevel': 'eventual'
      }
    });
    const j = await safeJson(r);
    if (r.ok && Array.isArray(j.value) && j.value.length > 0) {
      const pick = j.value.find(u => /@employsure\.(com\.au|co\.nz)$/i.test(u.userPrincipalName)) || j.value[0];
      return { id: pick.id, userPrincipalName: pick.userPrincipalName };
    }
  }

  // Optional domain rewrite fallback (commented out):
  // {
  //   const local = email.split('@')[0];
  //   const candidates = [
  //     `${local}@employsure.com.au`,
  //     `${local}@employsure.co.nz`
  //   ];
  //   for (const cand of candidates) {
  //     const r = await fetch(
  //       `https://graph.microsoft.com/v1.0/users/${encodeURIComponent(cand)}?$select=id,userPrincipalName`,
  //       { headers: { Authorization: `Bearer ${token}` } }
  //     );
  //     if (r.ok) {
  //       const j = await safeJson(r);
  //       if (j?.id) return { id: j.id, userPrincipalName: j.userPrincipalName };
  //     }
  //   }
  // }

  return null;
}

try {
  // === Token ===
  const tokenRes = await fetch(`https://login.microsoftonline.com/${tenantId}/oauth2/v2.0/token`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'client_credentials',
      client_id: clientId,
      client_secret: clientSecret,
      scope: 'https://graph.microsoft.com/.default'
    }).toString()
  });
  const token = await safeJson(tokenRes);
  if (!tokenRes.ok || !token.access_token) {
    return { success: false, stage: 'token', status: tokenRes.status, details: token };
  }
  const accessToken = token.access_token;

  // === Resolve organizer userId (objectId) ===
  const resolved = await resolveUserByEmail(organizerEmail, accessToken);
  if (!resolved?.id) {
    return {
      success: false,
      stage: 'resolve_user',
      error: `Could not resolve user from email: ${organizerEmail}`,
      hint: 'Try proxyAddresses/any or otherMails/any with ConsistencyLevel:eventual + $count=true.'
    };
  }
  const userId = resolved.id;

  // === calendarView with retries (stop only when we have an event WITH joinUrl) ===
  const startWindow = padMinutes(eventStart, -10);
  const endWindow = eventEnd ? padMinutes(eventEnd, 10) : padMinutes(eventStart, 40);

  const fetchCalendarOnce = async () => {
    const cvUrl =
      `https://graph.microsoft.com/v1.0/users/${encodeURIComponent(userId)}/calendarView` +
      `?startDateTime=${encodeURIComponent(startWindow)}` +
      `&endDateTime=${encodeURIComponent(endWindow)}` +
      `&$select=subject,start,end,onlineMeeting,onlineMeetingProvider,webLink,location`;

    const cvRes = await fetch(cvUrl, {
      headers: {
        Authorization: `Bearer ${accessToken}`,
        'Prefer': 'outlook.timezone="UTC"',
        'Content-Type': 'application/json'
      }
    });
    const cv = await safeJson(cvRes);
    return { cvRes, cv };
  };

  let ev = null, joinUrl = null, calendarRetriesUsed = 0;
  for (let attempt = 0; attempt <= CAL_MAX_RETRIES; attempt++) {
    if (attempt > 0) { await delay(CAL_DELAY_MS); calendarRetriesUsed++; }
    const { cvRes, cv } = await fetchCalendarOnce();

    if (!cvRes.ok) return { success: false, stage: 'calendar_view', status: cvRes.status, details: cv };
    if (!Array.isArray(cv.value) || cv.value.length === 0) {
      if (attempt === CAL_MAX_RETRIES) {
        return {
          success: false, stage: 'calendar_view',
          error: 'No events found in window after retries',
          retriesUsed: calendarRetriesUsed, organizerEmail, startWindow, endWindow
        };
      }
      continue;
    }

    if (calendlyUnique) {
      ev = cv.value.find(e => e?.location?.uniqueId === calendlyUnique);
    }
    if (!ev) {
      const target = new Date(eventStart).getTime();
      ev = cv.value.slice().sort((a, b) =>
        Math.abs(new Date(a.start.dateTime || a.start).getTime() - target) -
        Math.abs(new Date(b.start.dateTime || b.start).getTime() - target)
      )[0];
    }

    joinUrl = ev?.onlineMeeting?.joinUrl || null;
    if (joinUrl) break;

    if (attempt === CAL_MAX_RETRIES) {
      return {
        success: false, stage: 'calendar_view',
        error: 'Selected event has no onlineMeeting.joinUrl after retries (propagation lag)',
        retriesUsed: calendarRetriesUsed, sample: ev
      };
    }
  }

  // === per-user OnlineMeeting lookup with retries ===
  const buildLookupUrl = () =>
    `https://graph.microsoft.com/v1.0/users/${encodeURIComponent(userId)}` +
    `/onlineMeetings?$filter=JoinWebUrl eq ${odataString(joinUrl)}`;

  let onlineMeeting = null, lookupRetriesUsed = 0;
  for (let attempt = 0; attempt <= OM_MAX_RETRIES; attempt++) {
    if (attempt > 0) { await delay(OM_DELAY_MS); lookupRetriesUsed++; }
    const lookupUrl = buildLookupUrl();
    const omRes = await fetch(lookupUrl, { headers: { Authorization: `Bearer ${accessToken}` } });
    const om = await safeJson(omRes);

    if (omRes.ok && Array.isArray(om.value) && om.value.length > 0) {
      onlineMeeting = om.value[0];
      break;
    }

    if (attempt === OM_MAX_RETRIES) {
      return {
        success: false, stage: 'lookup_online_meeting',
        status: omRes.status,
        error: 'No onlineMeeting found via per-user JoinWebUrl filter after retries.',
        attempts: OM_MAX_RETRIES + 1, delay_ms: OM_DELAY_MS,
        requestTried: lookupUrl, response: om
      };
    }
  }

  const onlineMeetingId = onlineMeeting.id;

  // === PATCH: enable auto-recording (and allowRecording) ===
  const patchUrl =
    `https://graph.microsoft.com/v1.0/users/${encodeURIComponent(userId)}` +
    `/onlineMeetings/${encodeURIComponent(onlineMeetingId)}`;
  const patchBody = {
    allowRecording: true,        // obeys tenant policy
    recordAutomatically: true,   // start recording when meeting begins
    allowTranscription: true     // enable meeting transcription
    // Optional: set a spoken language tag for recording/transcription
    // meetingSpokenLanguageTag: "en-AU"
  };

  const updRes = await fetch(patchUrl, {
    method: 'PATCH',
    headers: { Authorization: `Bearer ${accessToken}`, 'Content-Type': 'application/json' },
    body: JSON.stringify(patchBody)
  });
  const upd = await safeJson(updRes);
  if (!updRes.ok) {
    return {
      success: false, stage: 'patch_online_meeting',
      status: updRes.status, details: upd,
      hint: 'Requires OnlineMeetings.ReadWrite.All and an Application Access Policy for this organizer.'
    };
  }

  // === Success ===
  return {
    success: true,
    stage: 'complete',
    calendarRetriesUsed,
    lookupRetriesUsed,
    organizer: { upn: resolved.userPrincipalName, id: userId, sourceEmail: organizerEmail },
    meeting: {
      id: onlineMeetingId,
      subject: onlineMeeting.subject || ev.subject || null,
      joinWebUrl: onlineMeeting.joinWebUrl || joinUrl
    },
    updated: patchBody,
    diagnostics: {
      window: { startWindow, endWindow },
      matchedBy: calendlyUnique ? 'location.uniqueId' : 'nearestStartTime'
    }
  };

} catch (err) {
  return { success: false, stage: 'unhandled', error: err?.message || String(err) };
}