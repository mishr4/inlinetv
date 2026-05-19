// Syncs the signed-in CiryaSSO user into our local Supabase `cirya_users` table.
// Loads the existing supabase-js client lazily; safe to include on any page.
(function() {
  'use strict';

  const SUPABASE_URL  = 'https://qiyxxjlekhnjthuepxzt.supabase.co';
  const SUPABASE_ANON = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFpeXh4amxla2huanRodWVweHp0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg0NTk2NDIsImV4cCI6MjA5NDAzNTY0Mn0.bRYA7hB5b3TZGlYJCJ06skDLEY6INGdFQztt89tIPWg';

  let synced = false;
  function getClient() {
    if (!window.supabase || !window.supabase.createClient) return null;
    if (!window.__inlinetvSb) {
      window.__inlinetvSb = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON);
    }
    return window.__inlinetvSb;
  }

  async function syncUser(user) {
    if (!user || !user.id || synced) return;
    const sb = getClient();
    if (!sb) return;
    try {
      const { error } = await sb.from('cirya_users').upsert({
        id: user.id,
        cirya_handle: user.cirya_handle || null,
        display_name: user.display_name || null,
        avatar_url:   user.avatar_url   || null,
        email:        user.email        || null,
        status:       user.status       || null,
        is_staff:    !!user.is_staff,
        is_plus:     !!user.is_plus,
        is_founder:  !!user.is_founder,
        badges:       user.badges       || [],
        last_seen_at: new Date().toISOString()
      }, { onConflict: 'id' });
      if (error) console.warn('[cirya-sync] failed:', error.message);
      else synced = true;
    } catch (e) {
      console.warn('[cirya-sync] threw:', e.message);
    }
  }

  function attach() {
    if (!window.CiryaSSO) return false;
    // If already signed in on first call, sync immediately
    window.CiryaSSO.user().then(u => { if (u) syncUser(u); });
    // And on every future sign-in
    window.CiryaSSO.on('signin', (u) => syncUser(u));
    return true;
  }

  // Poll until the SDK shows up (it loads async)
  if (!attach()) {
    const t = setInterval(() => { if (attach()) clearInterval(t); }, 250);
    setTimeout(() => clearInterval(t), 15000);
  }
})();
