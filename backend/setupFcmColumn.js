const supabase = require('./src/config/supabase');

async function setupFcmColumn() {
    console.log("🛠️ Attempting to verify or add fcm_token column in profiles table...");
    try {
        const { data, error } = await supabase.rpc('exec_sql', {
            sql_query: 'ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS fcm_token TEXT;'
        });

        if (error) {
            console.log("ℹ️ Please run this SQL query directly in Supabase SQL Editor:");
            console.log("\n==================================================");
            console.log("ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS fcm_token TEXT;");
            console.log("==================================================\n");
        } else {
            console.log("✅ Successfully verified fcm_token column in Supabase!");
        }
    } catch (e) {
        console.log("ℹ️ Please run this SQL query directly in Supabase SQL Editor:");
        console.log("\n==================================================");
        console.log("ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS fcm_token TEXT;");
        console.log("==================================================\n");
    }
}

setupFcmColumn();
