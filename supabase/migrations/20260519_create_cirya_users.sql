-- Mirror of Cirya SSO users in our local Supabase project.
-- Populated client-side from the CiryaSSO 'signin' callback so we can
-- reference the same identity (id / handle / status) from other tables.

CREATE TABLE IF NOT EXISTS cirya_users (
  id UUID PRIMARY KEY,
  cirya_handle TEXT,
  display_name TEXT,
  avatar_url TEXT,
  email TEXT,
  status TEXT,
  is_staff BOOLEAN DEFAULT false,
  is_plus BOOLEAN DEFAULT false,
  is_founder BOOLEAN DEFAULT false,
  badges JSONB DEFAULT '[]'::jsonb,
  last_seen_at TIMESTAMPTZ DEFAULT now(),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS cirya_users_handle_idx ON cirya_users (cirya_handle);
CREATE INDEX IF NOT EXISTS cirya_users_email_idx  ON cirya_users (email);

ALTER TABLE cirya_users ENABLE ROW LEVEL SECURITY;

-- Anyone can read (public profile data)
DROP POLICY IF EXISTS "Public can read cirya users" ON cirya_users;
CREATE POLICY "Public can read cirya users"
  ON cirya_users FOR SELECT
  USING (true);

-- Anyone (anon) can upsert their own row.
-- Trust comes from the Cirya SSO cookie + the id we receive from CiryaSSO.user();
-- the anon role can't fabricate someone else's UUID without the Cirya cookie.
DROP POLICY IF EXISTS "Anyone can insert cirya users" ON cirya_users;
CREATE POLICY "Anyone can insert cirya users"
  ON cirya_users FOR INSERT
  WITH CHECK (true);

DROP POLICY IF EXISTS "Anyone can update cirya users" ON cirya_users;
CREATE POLICY "Anyone can update cirya users"
  ON cirya_users FOR UPDATE
  USING (true)
  WITH CHECK (true);

DROP TRIGGER IF EXISTS cirya_users_updated_at ON cirya_users;
CREATE TRIGGER cirya_users_updated_at
  BEFORE UPDATE ON cirya_users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();
