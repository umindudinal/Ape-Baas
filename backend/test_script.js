const supabase = require('./src/config/supabase');

async function test() {
  const { data, error } = await supabase.from('categories').select('*');
  console.log('Data:', data);
  console.log('Error:', error);
}

test();
