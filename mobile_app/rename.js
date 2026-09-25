const fs = require('fs');
const path = require('path');

const targetDir = path.join(__dirname, 'assets', 'customer');

if (!fs.existsSync(targetDir)) {
  console.error('Target directory not found:', targetDir);
  process.exit(1);
}

const files = fs.readdirSync(targetDir);
console.log(`Found ${files.length} files in assets/customer`);

files.forEach(file => {
  let newName = null;

  if (file.toLowerCase().includes('banner sinhala')) {
    newName = 'banner_sinhala.png';
  } else if (file === 'Banner.png') {
    newName = 'banner.png';
  } else if (file.includes('CCTV')) {
    newName = 'cctv.png';
  } else if (file.includes('ඇලුමිනියම්')) {
    newName = 'aluminum.png';
  } else if (file.includes('ඒසී')) {
    newName = 'ac_repair.png';
  } else if (file.includes('කෘමීන්')) {
    newName = 'pest_control.png';
  } else if (file.includes('ටයිල්')) {
    newName = 'tile_flooring.png';
  } else if (file.includes('තීන්ත')) {
    newName = 'painting.png';
  } else if (file.includes('නළ')) {
    newName = 'plumbing.png';
  } else if (file.includes('ගෘහභාණ්ඩ')) {
    newName = 'transport.png';
  } else if (file.includes('පිරිසිදු')) {
    newName = 'cleaning.png';
  } else if (file.includes('මේසන්')) {
    newName = 'masonry.png';
  } else if (file.includes('වඩු')) {
    newName = 'carpentry.png';
  } else if (file.includes('වතුර')) {
    newName = 'water_pump.png';
  } else if (file.includes('විදුලි')) {
    newName = 'electrician.png';
  } else if (file.includes('සෞර')) {
    newName = 'solar.png';
  } else if (file.includes('රෙදි') || file.includes('යන්')) {
    newName = 'washing_machine.png';
  }

  if (newName) {
    const oldPath = path.join(targetDir, file);
    const newPath = path.join(targetDir, newName);
    try {
      fs.renameSync(oldPath, newPath);
      console.log(`✅ Renamed: "${file}" -> "${newName}"`);
    } catch (e) {
      console.error(`❌ Failed to rename "${file}":`, e.message);
    }
  }
});

console.log('🎉 Done renaming assets!');
