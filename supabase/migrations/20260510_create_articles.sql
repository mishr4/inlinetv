-- Articles table for stories/news on the homepage
CREATE TABLE IF NOT EXISTS articles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  category TEXT NOT NULL CHECK (category IN ('robloxians', 'meetings', 'voice', 'news', 'general')),
  title TEXT NOT NULL,
  body TEXT,
  image_url TEXT,
  author_email TEXT,
  published BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE articles ENABLE ROW LEVEL SECURITY;

-- Public can read published articles
CREATE POLICY "Public can read published articles"
  ON articles FOR SELECT
  USING (published = true);

-- Only @cirya.co staff can manage articles
CREATE POLICY "Staff can manage articles"
  ON articles FOR ALL
  TO authenticated
  USING (auth.jwt() ->> 'email' LIKE '%@cirya.co')
  WITH CHECK (auth.jwt() ->> 'email' LIKE '%@cirya.co');

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER articles_updated_at
  BEFORE UPDATE ON articles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- Seed with the existing stories from the Framer design
INSERT INTO articles (category, title, published) VALUES
  ('robloxians', 'RoTV Pro comes out', true),
  ('meetings', 'Is it difficult to make an app?', true),
  ('voice', 'Bixby Vs. Google', true);
