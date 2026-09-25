const supabase = require('./src/config/supabase');

const INITIAL_CATEGORIES = [
  { id: 'cat-1', name_si: 'විදුලි කාර්මික සේවා', name_en: 'Electrician Services', icon: 'Zap', status: 'Active', provider_count: 48, base_price: 2500 },
  { id: 'cat-2', name_si: 'නළ එළීමේ සහ ජලනල සේවා', name_en: 'Plumbing & Water Lines', icon: 'Wrench', status: 'Active', provider_count: 52, base_price: 2000 },
  { id: 'cat-3', name_si: 'වඩු කාර්මික සේවා', name_en: 'Carpentry & Woodwork', icon: 'Hammer', status: 'Active', provider_count: 35, base_price: 3000 },
  { id: 'cat-4', name_si: 'ඒසී (A/C) අලුත්වැඩියාව සහ නඩත්තුව', name_en: 'AC Repair & Service', icon: 'Wind', status: 'Active', provider_count: 41, base_price: 4500 },
  { id: 'cat-5', name_si: 'මේසන් සහ ගොඩනැගිලි වැඩ', name_en: 'Masonry & Construction', icon: 'Building', status: 'Active', provider_count: 29, base_price: 3500 },
  { id: 'cat-6', name_si: 'තීන්ත ආලේපනය', name_en: 'House Painting', icon: 'Paintbrush', status: 'Active', provider_count: 38, base_price: 3000 },
  { id: 'cat-7', name_si: 'ටයිල් එළීම සහ පොළොව සැකසීම', name_en: 'Tile Laying & Flooring', icon: 'Grid', status: 'Active', provider_count: 24, base_price: 4000 },
  { id: 'cat-8', name_si: 'ගෙවතු අලංකරණය සහ නඩත්තුව', name_en: 'Gardening & Landscaping', icon: 'Trees', status: 'Active', provider_count: 30, base_price: 2500 },
  { id: 'cat-9', name_si: 'නිවාස පිරිසිදු කිරීම', name_en: 'House Deep Cleaning', icon: 'Sparkles', status: 'Active', provider_count: 60, base_price: 5000 },
  { id: 'cat-10', name_si: 'සෞර ශක්ති (Solar) පද්ධති සවිකිරීම', name_en: 'Solar Panel Installation', icon: 'Sun', status: 'Active', provider_count: 18, base_price: 15000 },
  { id: 'cat-11', name_si: 'CCTV සහ ආරක්ෂක කැමරා', name_en: 'CCTV & Security Systems', icon: 'Camera', status: 'Active', provider_count: 33, base_price: 6000 },
  { id: 'cat-12', name_si: 'ගෘහ උපකරණ අලුත්වැඩියාව', name_en: 'Appliance Repair', icon: 'Tv', status: 'Active', provider_count: 45, base_price: 2500 },
  { id: 'cat-13', name_si: 'වහල අලුත්වැඩියාව සහ කාන්දුවීම්', name_en: 'Roof Repair & Waterproofing', icon: 'Home', status: 'Active', provider_count: 22, base_price: 4500 },
  { id: 'cat-14', name_si: 'කෘමීන් සහ පළිබෝධ පාලනය', name_en: 'Pest Control', icon: 'Bug', status: 'Active', provider_count: 19, base_price: 7000 },
  { id: 'cat-15', name_si: 'වාහන අලුත්වැඩියාව සහ සේවා', name_en: 'Mobile Vehicle Mechanics', icon: 'Car', status: 'Active', provider_count: 37, base_price: 3500 },
  { id: 'cat-16', name_si: 'රෙදි සෝදන යන්ත්‍ර අලුත්වැඩියාව', name_en: 'Washing Machine Repair', icon: 'Shirt', status: 'Active', provider_count: 28, base_price: 3000 },
  { id: 'cat-17', name_si: 'ශීතකරණ අලුත්වැඩියාව', name_en: 'Refrigerator Repair', icon: 'Snowflake', status: 'Active', provider_count: 31, base_price: 3500 },
  { id: 'cat-18', name_si: 'ඇලුමිනියම් පද්ධති සවිකිරීම', name_en: 'Aluminum Fabrication', icon: 'Layers', status: 'Active', provider_count: 26, base_price: 5000 },
  { id: 'cat-19', name_si: 'වෙල්ඩින් සහ යකඩ වැඩ', name_en: 'Welding & Ironworks', icon: 'Flame', status: 'Active', provider_count: 27, base_price: 4000 },
  { id: 'cat-20', name_si: 'අභ්‍යන්තර අලංකරණය (Interior Design)', name_en: 'Interior Designing', icon: 'Layout', status: 'Active', provider_count: 15, base_price: 12000 },
  { id: 'cat-21', name_si: 'වතුර ටැංකි පිරිසිදු කිරීම', name_en: 'Water Tank Cleaning', icon: 'Droplets', status: 'Active', provider_count: 34, base_price: 3000 },
  { id: 'cat-22', name_si: 'තණකොළ කැපීම සහ සුද්ධ කිරීම', name_en: 'Lawn Mowing & Yard Clean', icon: 'Scissors', status: 'Active', provider_count: 40, base_price: 2000 },
  { id: 'cat-23', name_si: 'පීලි (Gutters) සුද්ධ කිරීම', name_en: 'Gutter Cleaning', icon: 'CloudRain', status: 'Active', provider_count: 21, base_price: 2500 },
  { id: 'cat-24', name_si: 'ගෘහ භාණ්ඩ අලුත්වැඩියාව සහ පොලිෂ්', name_en: 'Furniture Polish & Repair', icon: 'Armchair', status: 'Active', provider_count: 23, base_price: 3500 },
  { id: 'cat-25', name_si: 'යතුරු සාදන්නන් සහ උගුල් ඇරීම', name_en: 'Locksmith & Key Service', icon: 'Key', status: 'Active', provider_count: 32, base_price: 2000 },
  { id: 'cat-26', name_si: 'හදිසි විදුලි පද්ධති පරීක්ෂාව', name_en: 'Emergency Electrical Fix', icon: 'ShieldAlert', status: 'Active', provider_count: 50, base_price: 3000 },
  { id: 'cat-27', name_si: 'සෙප්ටික් ටැංකි සුද්ධ කිරීම', name_en: 'Septic Tank Cleaning', icon: 'Trash2', status: 'Active', provider_count: 14, base_price: 8500 },
  { id: 'cat-28', name_si: 'දුම් කවුළු සහ කුස්සි පෝරණු සුද්ධය', name_en: 'Kitchen Hood Cleaning', icon: 'Flame', status: 'Active', provider_count: 18, base_price: 4000 },
  { id: 'cat-29', name_si: 'පිහිනුම් තටාක නඩත්තුව', name_en: 'Swimming Pool Maintenance', icon: 'Waves', status: 'Active', provider_count: 12, base_price: 10000 },
  { id: 'cat-30', name_si: 'නිවාස ගෘහභාණ්ඩ ප්‍රවාහනය', name_en: 'House Moving & Transport', icon: 'Truck', status: 'Active', provider_count: 36, base_price: 9000 },
  { id: 'cat-31', name_si: 'සෝෆා සහ කුෂන් පිරිසිදු කිරීම', name_en: 'Sofa & Cushion Washing', icon: 'Armchair', status: 'Active', provider_count: 29, base_price: 4500 },
  { id: 'cat-32', name_si: 'කාපට් හෝදනය සහ පිරිසිදුව', name_en: 'Carpet Deep Wash', icon: 'Grid', status: 'Active', provider_count: 25, base_price: 4000 },
  { id: 'cat-33', name_si: 'ලී පොළොව පොලිෂ් කිරීම', name_en: 'Wooden Floor Polishing', icon: 'Layers', status: 'Active', provider_count: 17, base_price: 6000 },
  { id: 'cat-34', name_si: 'වීදුරු සහ ජනෙල් පිරිසිදු කිරීම', name_en: 'Glass & Window Cleaning', icon: 'Maximize2', status: 'Active', provider_count: 31, base_price: 3000 },
  { id: 'cat-35', name_si: 'ජෙනරේටර් (Generator) අලුත්වැඩියාව', name_en: 'Generator Maintenance', icon: 'Cpu', status: 'Active', provider_count: 16, base_price: 6500 },
  { id: 'cat-36', name_si: 'සූරිය උණු වතුර (Solar Heater) පද්ධති', name_en: 'Solar Water Heater Repair', icon: 'Thermometer', status: 'Active', provider_count: 20, base_price: 4000 },
  { id: 'cat-37', name_si: 'ගීසර් (Geyser) අලුත්වැඩියාව', name_en: 'Water Heater Fix', icon: 'Zap', status: 'Active', provider_count: 33, base_price: 3000 },
  { id: 'cat-38', name_si: 'ස්මාර්ට් හෝම් (Smart Home) සැකසීම', name_en: 'Smart Home Automation', icon: 'Smartphone', status: 'Active', provider_count: 14, base_price: 8000 },
  { id: 'cat-39', name_si: 'වෝල් පේපර් (Wallpaper) ඇලවීම', name_en: 'Wallpaper Installation', icon: 'Image', status: 'Active', provider_count: 22, base_price: 3500 },
  { id: 'cat-40', name_si: 'තිර රෙදි (Curtains) සවිකිරීම', name_en: 'Curtain Rods & Blind Fix', icon: 'Maximize', status: 'Active', provider_count: 24, base_price: 2500 },
  { id: 'cat-41', name_si: 'ටීවී (TV) බිත්තියේ සවිකිරීම', name_en: 'TV Mounting & Setup', icon: 'Tv', status: 'Active', provider_count: 42, base_price: 2000 },
  { id: 'cat-42', name_si: 'ශබ්ද පද්ධති (Sound System) සැකසුම්', name_en: 'Sound System Setup', icon: 'Volume2', status: 'Active', provider_count: 19, base_price: 3000 },
  { id: 'cat-43', name_si: 'වතුර මෝටර් (Water Pump) අලුත්වැඩියාව', name_en: 'Water Pump Repair', icon: 'Zap', status: 'Active', provider_count: 44, base_price: 3000 },
  { id: 'cat-44', name_si: 'විෂබීජ හරණය සහ ධූමකරණය', name_en: 'Disinfection & Sanitization', icon: 'Shield', status: 'Active', provider_count: 28, base_price: 5000 },
  { id: 'cat-45', name_si: 'දොර සහ ජනෙල් සගල (Hinges) අලුත්වැඩියාව', name_en: 'Door & Window Hinges Fix', icon: 'Settings', status: 'Active', provider_count: 30, base_price: 2000 },
  { id: 'cat-46', name_si: 'ගෑස් ලිප් (Gas Stove) අලුත්වැඩියාව', name_en: 'Gas Stove & Oven Repair', icon: 'Flame', status: 'Active', provider_count: 35, base_price: 2500 },
  { id: 'cat-47', name_si: 'ඡායාරූප සහ චිත්‍ර රාමු සවිකිරීම', name_en: 'Wall Art & Mirror Hanging', icon: 'Square', status: 'Active', provider_count: 38, base_price: 1500 },
  { id: 'cat-48', name_si: 'මයික්‍රෝවේව් (Microwave) අලුත්වැඩියාව', name_en: 'Microwave Oven Repair', icon: 'Box', status: 'Active', provider_count: 27, base_price: 2500 },
  { id: 'cat-49', name_si: 'මදුරු ජාලා (Mosquito Net) සවිකිරීම', name_en: 'Mosquito Net Installation', icon: 'Grid', status: 'Active', provider_count: 25, base_price: 3000 },
  { id: 'cat-50', name_si: 'වහල පරාල සහ ලෑලි සේවාවන්', name_en: 'Roof Truss & Battens Work', icon: 'Home', status: 'Active', provider_count: 16, base_price: 5500 }
];

async function seedCategories() {
  console.log('⏳ Seeding 50 Categories into Supabase database...');

  const { data, error } = await supabase
    .from('categories')
    .upsert(INITIAL_CATEGORIES, { onConflict: 'id' });

  if (error) {
    console.error('❌ Error inserting categories:', error.message);
    if (error.message.includes('relation "public.categories" does not exist')) {
      console.log('\n📌 NOTE: The "categories" table does not exist in Supabase yet.');
      console.log('Please execute the following SQL query in your Supabase SQL Editor:\n');
      console.log(`
CREATE TABLE IF NOT EXISTS categories (
    id TEXT PRIMARY KEY,
    name_si TEXT NOT NULL,
    name_en TEXT NOT NULL,
    icon TEXT DEFAULT 'Wrench',
    status TEXT DEFAULT 'Active',
    provider_count INT DEFAULT 0,
    base_price NUMERIC DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
      `);
    }
  } else {
    console.log('🎉 Successfully saved 50 categories to Supabase database!');
  }
}

seedCategories();
