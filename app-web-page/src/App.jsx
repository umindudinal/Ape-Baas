import Navbar from './components/Navbar';
import Hero from './components/Hero';
import ServicesSection from './components/ServicesSection';
import FeaturesSection from './components/FeaturesSection';
import HowItWorks from './components/HowItWorks';
import AppShowcase from './components/AppShowcase';
import InstallationGuide from './components/InstallationGuide';
import Testimonials from './components/Testimonials';
import FAQSection from './components/FAQSection';
import Footer from './components/Footer';
import FloatingWidget from './components/FloatingWidget';
import ScrollReveal from './components/ScrollReveal';

function App() {
  return (
    <div className="min-h-screen bg-slate-50 text-slate-900 font-sans selection:bg-[#002B49] selection:text-white relative">
      
      {/* Sticky Floating Glass Navbar */}
      <Navbar />

      {/* Main Full Page Sections */}
      <main>
        {/* Hero Section */}
        <Hero />

        {/* Services Categories */}
        <ServicesSection />

        {/* Built for Safety & Trust Features Grid */}
        <FeaturesSection />

        {/* 4-Step 60-Second Booking Journey */}
        <HowItWorks />

        {/* Mobile App Showcase & Screen Switcher */}
        <AppShowcase />

        {/* 5-Step Android APK Installation Guide */}
        <InstallationGuide />

        {/* Early Customer Reviews */}
        <Testimonials />

        {/* Accordion FAQ */}
        <FAQSection />
      </main>

      {/* Grounded Deep Midnight Navy Footer */}
      <Footer />

      {/* Dynamic Floating Quick Action & Back-to-Top Widget */}
      <FloatingWidget />

    </div>
  );
}

export default App;
