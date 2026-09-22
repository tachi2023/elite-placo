const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');
const https = require('https');

const downloadImage = (url, filepath) => {
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      if (res.statusCode === 200) {
        res.pipe(fs.createWriteStream(filepath))
           .on('error', reject)
           .once('close', () => resolve(filepath));
      } else if (res.statusCode === 301 || res.statusCode === 302) {
        downloadImage(res.headers.location, filepath).then(resolve).catch(reject);
      } else {
        res.resume();
        reject(new Error(`Request Failed With a Status Code: ${res.statusCode}`));
      }
    }).on('error', reject);
  });
};

(async () => {
  console.log('Lancement du navigateur...');
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.goto('https://elite-cosmos-build.lovable.app/', { waitUntil: 'networkidle' });

  console.log('Extraction des images...');
  const imageUrls = await page.evaluate(() => {
    const images = Array.from(document.querySelectorAll('img')).map(img => img.src);
    const bgImages = Array.from(document.querySelectorAll('*')).map(el => {
      const bg = window.getComputedStyle(el).backgroundImage;
      if (bg !== 'none' && bg.includes('url(')) {
        return bg.slice(5, -2).replace(/"/g, "");
      }
      return null;
    }).filter(Boolean);
    return [...new Set([...images, ...bgImages])];
  });

  console.log(`Trouvé ${imageUrls.length} images uniques.`);
  
  const publicDir = path.join(__dirname, 'public', 'assets');
  if (!fs.existsSync(publicDir)) {
    fs.mkdirSync(publicDir, { recursive: true });
  }

  for (let i = 0; i < imageUrls.length; i++) {
    let url = imageUrls[i];
    if (url.startsWith('//')) {
      url = 'https:' + url;
    } else if (url.startsWith('/')) {
      url = 'https://elite-cosmos-build.lovable.app' + url;
    }
    
    if (!url.startsWith('http')) continue;

    try {
      let fileName = `image_${i}.jpg`;
      const urlObj = new URL(url);
      const pathname = urlObj.pathname;
      const ext = path.extname(pathname);
      if (ext && ext.length < 5) fileName = `image_${i}${ext}`;
      
      const filepath = path.join(publicDir, fileName);
      console.log(`Téléchargement de ${url} vers ${fileName}`);
      await downloadImage(url, filepath);
    } catch (err) {
      console.error(`Erreur sur l'image ${url}: ${err.message}`);
    }
  }

  await browser.close();
  console.log('Téléchargement terminé !');
})();
