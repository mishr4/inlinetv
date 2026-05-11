-- Pages table for custom CMS pages
CREATE TABLE IF NOT EXISTS pages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  slug TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  description TEXT,
  cover_image TEXT,
  blocks JSONB DEFAULT '[]'::jsonb,
  published BOOLEAN DEFAULT false,
  author_email TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE pages ENABLE ROW LEVEL SECURITY;

-- Public can read published pages
CREATE POLICY "Public can read published pages"
  ON pages FOR SELECT
  USING (published = true);

-- Only @cirya.co staff can manage pages
CREATE POLICY "Staff can manage pages"
  ON pages FOR ALL
  TO authenticated
  USING (auth.jwt() ->> 'email' LIKE '%@cirya.co')
  WITH CHECK (auth.jwt() ->> 'email' LIKE '%@cirya.co');

-- Auto-update updated_at (reuse function from articles migration)
CREATE TRIGGER pages_updated_at
  BEFORE UPDATE ON pages
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();
