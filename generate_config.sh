#!/bin/bash
# Netlify Pre-Build Script
# Generates assets/app_config.json dynamically from Netlify Environment Variables

mkdir -p assets

cat <<EOF > assets/app_config.json
{
  "SUPABASE_URL": "$SUPABASE_URL",
  "SUPABASE_ANON_KEY": "$SUPABASE_ANON_KEY",
  "GEMINI_API_KEY": "$GEMINI_API_KEY"
}
EOF

echo "Successfully generated assets/app_config.json from Netlify Environment Variables."
