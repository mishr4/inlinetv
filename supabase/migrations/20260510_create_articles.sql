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

-- Seed with stories
INSERT INTO articles (category, title, body, image_url, published) VALUES
  ('news', 'Inline TV Launches New Streaming Platform',
   'Inline TV is officially live! Our brand-new streaming platform brings you original shows, live broadcasts, and on-demand content — all in one place. Built from the ground up by the TMC Media team.',
   'https://images.unsplash.com/photo-1611162617213-7d7a39e9b1d7?w=800&h=450&fit=crop', true),

  ('robloxians', 'Inline Studios Launches Creator Tools for Roblox',
   'The next generation of Roblox content creation is here. Inline Studios gives creators a full suite of tools to produce, broadcast, and monetize their shows inside the Roblox ecosystem.',
   'https://images.unsplash.com/photo-1616588589676-62b3d4ff6643?w=800&h=450&fit=crop', true),

  ('meetings', 'Behind the Scenes: Building an App from Scratch',
   'Our dev team walks you through the journey of building the Inline TV app — from initial wireframes and tech stack decisions to launch day. Spoiler: it was harder than we thought.',
   'https://images.unsplash.com/photo-1531482615713-2afd69097998?w=800&h=450&fit=crop', true),

  ('voice', 'Voice Wars: Bixby vs. Google Assistant in 2026',
   'We put Samsung Bixby and Google Assistant head-to-head in a series of real-world tasks. Which AI voice assistant actually gets things done? The results might surprise you.',
   'https://images.unsplash.com/photo-1589254065878-42c9da997008?w=800&h=450&fit=crop', true),

  ('news', 'TMC Media Expands into Podcast Network',
   'TMC Media announces the launch of its dedicated podcast division. With three flagship shows already in production, the network aims to become a go-to destination for audio content.',
   'https://images.unsplash.com/photo-1478737270239-2f02b77fc618?w=800&h=450&fit=crop', true),

  ('general', 'The Future of Independent Media in a Streaming World',
   'As major platforms battle for subscribers, independent media outlets like Inline TV are carving out a niche. We explore what it takes to compete — and why authenticity wins.',
   'https://images.unsplash.com/photo-1504711434969-e33886168d6c?w=800&h=450&fit=crop', true);
