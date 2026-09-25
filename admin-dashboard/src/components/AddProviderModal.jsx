import React, { useState, useEffect } from 'react';
import { createPortal } from 'react-dom';
import { 
  X, 
  UserPlus, 
  User, 
  Mail, 
  Phone, 
  Lock, 
  Eye, 
  EyeOff, 
  Wrench, 
  MapPin, 
  ShieldCheck, 
  CheckCircle2, 
  AlertCircle, 
  Sparkles, 
  Clock, 
  Compass, 
  CreditCard, 
  Building, 
  RefreshCw,
  Zap,
  Hammer,
  Wind,
  Paintbrush,
  Grid,
  Trees,
  Sun,
  Camera,
  Tv,
  Home,
  Bug,
  Truck,
  Shirt,
  Snowflake,
  Flame,
  Droplets,
  Key,
  Cpu,
  Volume2,
  Thermometer,
  Shield,
  Layers,
  Scissors
} from 'lucide-react';
import { createProviderApi, createCategoryApi } from '../services/api';

const ICON_MAP = {
  Zap, Wrench, Hammer, Wind, Building, Paintbrush, Grid, Trees, Sparkles, 
  Sun, Camera, Tv, Home, Bug, Truck, Shirt, Snowflake, Flame, Droplets, 
  Key, Cpu, Volume2, Thermometer, Shield, Layers, Scissors
};

const AVAILABLE_ICONS = [
  'Wrench', 'Zap', 'Hammer', 'Wind', 'Paintbrush', 'Grid', 'Trees', 
  'Sparkles', 'Sun', 'Camera', 'Droplets', 'Flame', 'Truck', 'Snowflake', 
  'Home', 'Bug', 'Key', 'Cpu', 'Tv', 'Building', 'Shirt', 'Volume2'
];

// 25 Sri Lankan Districts with English & Sinhala Names
const SRI_LANKA_DISTRICTS_BILINGUAL = [
  { id: 'Colombo', en: 'Colombo', si: 'කොළඹ' },
  { id: 'Gampaha', en: 'Gampaha', si: 'ගම්පහ' },
  { id: 'Kalutara', en: 'Kalutara', si: 'කළුතර' },
  { id: 'Kandy', en: 'Kandy', si: 'මහනුවර' },
  { id: 'Matale', en: 'Matale', si: 'මාතලේ' },
  { id: 'Nuwara Eliya', en: 'Nuwara Eliya', si: 'නුවරඑළිය' },
  { id: 'Galle', en: 'Galle', si: 'ගාල්ල' },
  { id: 'Matara', en: 'Matara', si: 'මාතර' },
  { id: 'Hambantota', en: 'Hambantota', si: 'හම්බන්තොට' },
  { id: 'Jaffna', en: 'Jaffna', si: 'යාපනය' },
  { id: 'Kilinochchi', en: 'Kilinochchi', si: 'කිලිනොච්චිය' },
  { id: 'Mannar', en: 'Mannar', si: 'මන්නාරම' },
  { id: 'Vavuniya', en: 'Vavuniya', si: 'වවුනියාව' },
  { id: 'Mullaitivu', en: 'Mullaitivu', si: 'මුලතිව්' },
  { id: 'Batticaloa', en: 'Batticaloa', si: 'මඩකලපුව' },
  { id: 'Ampara', en: 'Ampara', si: 'අම්පාර' },
  { id: 'Trincomalee', en: 'Trincomalee', si: 'ත්‍රිකුණාමලය' },
  { id: 'Kurunegala', en: 'Kurunegala', si: 'කුරුණෑගල' },
  { id: 'Puttalam', en: 'Puttalam', si: 'පුත්තලම' },
  { id: 'Anuradhapura', en: 'Anuradhapura', si: 'අනුරාධපුරය' },
  { id: 'Polonnaruwa', en: 'Polonnaruwa', si: 'පොළොන්නරුව' },
  { id: 'Badulla', en: 'Badulla', si: 'බදුල්ල' },
  { id: 'Monaragala', en: 'Monaragala', si: 'මොණරාගල' },
  { id: 'Ratnapura', en: 'Ratnapura', si: 'රත්නපුරය' },
  { id: 'Kegalle', en: 'Kegalle', si: 'කෑගල්ල' }
];

// Comprehensive 25 Sri Lankan Districts & Their Associated Major Cities / Towns (Bilingual)
const SRI_LANKA_DISTRICT_CITIES_BILINGUAL = {
  'Colombo': [
    { en: 'Colombo 01 - Fort', si: 'කොටුව' },
    { en: 'Colombo 02 - Slave Island', si: 'කොම්පඤ්ඤවීදිය' },
    { en: 'Colombo 03 - Kollupitiya', si: 'කොල්ලුපිටිය' },
    { en: 'Colombo 04 - Bambalapitiya', si: 'බම්බලපිටිය' },
    { en: 'Colombo 05 - Havelock Town / Kirulapone / Narahenpita', si: 'හැව්ලොක් ටවුන් / කිරුළපන / නාරාහේන්පිට' },
    { en: 'Colombo 06 - Wellawatte / Pamankada', si: 'වැල්ලවත්ත / පාමංකඩ' },
    { en: 'Colombo 07 - Cinnamon Gardens', si: 'කුරුඳුවත්ත' },
    { en: 'Colombo 08 - Borella', si: 'බොරැල්ල' },
    { en: 'Colombo 09 - Dematagoda', si: 'දෙමටගොඩ' },
    { en: 'Colombo 10 - Maradana / Panchikawatta', si: 'මරදාන / පංචිකාවත්ත' },
    { en: 'Colombo 11 - Pettah', si: 'පිටකොටුව' },
    { en: 'Colombo 12 - Hulftsdorp / Aluthkade', si: 'අලුත්කඩේ' },
    { en: 'Colombo 13 - Kotahena / Kochchikade / Bloemendhal', si: 'කොටහේන / කොච්චිකඩේ / බ්ලුමැන්ඩල්' },
    { en: 'Colombo 14 - Grandpass / Totalanga', si: 'ග්‍රෑන්ඩ්පාස් / තොටළඟ' },
    { en: 'Colombo 15 - Mattakkuliya / Modara / Mutwal', si: 'මට්ටක්කුලිය / මෝදර / මුතුවල්' },
    { en: 'Moratuwa', si: 'මොරටුව' },
    { en: 'Sri Jayawardenepura Kotte', si: 'ශ්‍රී ජයවර්ධනපුර කෝට්ටේ' },
    { en: 'Dehiwala', si: 'දෙහිවල' },
    { en: 'Mount Lavinia', si: 'ගල්කිස්ස' },
    { en: 'Kaduwela', si: 'කඩුවෙල' },
    { en: 'Maharagama', si: 'මහරගම' },
    { en: 'Kesbewa', si: 'කැස්බෑව' },
    { en: 'Homagama', si: 'හෝමාගම' },
    { en: 'Kolonnawa', si: 'කොලොන්නාව' },
    { en: 'Padukka', si: 'පාදුක්ක' },
    { en: 'Ratmalana', si: 'රත්මලාන' },
    { en: 'Avissawella', si: 'අවිස්සාවේල්ල' },
    { en: 'Rajagiriya', si: 'රාජගිරිය' },
    { en: 'Nawala', si: 'නාවල' },
    { en: 'Battaramulla', si: 'බත්තරමුල්ල' },
    { en: 'Kotte', si: 'කෝට්ටේ' },
    { en: 'Piliyandala', si: 'පිළියන්දල' },
    { en: 'Malabe', si: 'මාලබේ' },
    { en: 'Meegoda', si: 'මීගොඩ' },
    { en: 'Pugoda', si: 'පූගොඩ' },
    { en: 'Kottawa', si: 'කොට්ටාව' },
    { en: 'Pannipitiya', si: 'පන්නිපිටිය' },
    { en: 'Athurugiriya', si: 'අතුරුගිරිය' },
    { en: 'Hanwella', si: 'හංවැල්ල' },
    { en: 'Boralesgamuwa', si: 'බොරලැස්ගමුව' },
    { en: 'Kohuwala', si: 'කොහුවල' }
  ],
  'Gampaha': [
    { en: 'Gampaha', si: 'ගම්පහ' },
    { en: 'Negombo', si: 'මීගමුව' },
    { en: 'Katunayake - Seeduwa', si: 'කටුනායක - සීදුව' },
    { en: 'Minuwangoda', si: 'මිනුවන්ගොඩ' },
    { en: 'Wattala - Mabola', si: 'වත්තල - මාබෝල' },
    { en: 'Ja-Ela', si: 'ජා-ඇල' },
    { en: 'Peliyagoda', si: 'පෑලියගොඩ' },
    { en: 'Kelaniya', si: 'කැලණිය' },
    { en: 'Kiribathgoda', si: 'කිරිබත්ගොඩ' },
    { en: 'Kadawatha', si: 'කඩවත' },
    { en: 'Ragama', si: 'රාගම' },
    { en: 'Kandana', si: 'කඳාන' },
    { en: 'Ganemulla', si: 'ගනේමුල්ල' },
    { en: 'Yakkala', si: 'යක්කල' },
    { en: 'Nittambuwa', si: 'නිට්ටඹුව' },
    { en: 'Veyangoda', si: 'වේයන්ගොඩ' },
    { en: 'Mirigama', si: 'මීරිගම' },
    { en: 'Divulapitiya', si: 'දිවුලපිටිය' },
    { en: 'Biyagama', si: 'බියගම' },
    { en: 'Delgoda', si: 'දෙල්ගොඩ' },
    { en: 'Weliweriya', si: 'වැලිවේරිය' },
    { en: 'Dompe', si: 'දොම්පේ' },
    { en: 'Kirindiwela', si: 'කිරිඳිවැල' },
    { en: 'Mahara', si: 'මහර' },
    { en: 'Udugampola', si: 'උඩුගම්පොළ' },
    { en: 'Radawana', si: 'රදාවාන' },
    { en: 'Pugoda', si: 'පූගොඩ' },
    { en: 'Uswetakeiyawa', si: 'උස්වැටකෙයියාව' }
  ],
  'Kalutara': [
    { en: 'Kalutara', si: 'කළුතර' },
    { en: 'Panadura', si: 'පානදුර' },
    { en: 'Horana', si: 'හොරණ' },
    { en: 'Beruwala', si: 'බේරුවල' },
    { en: 'Matugama', si: 'මතුගම' },
    { en: 'Bandaragama', si: 'බණ්ඩාරගම' },
    { en: 'Aluthgama', si: 'අලුත්ගම' },
    { en: 'Wadduwa', si: 'වාද්දුව' },
    { en: 'Agalawatta', si: 'අගලවත්ත' },
    { en: 'Bulathsinhala', si: 'බුලත්සිංහල' },
    { en: 'Ingiriya', si: 'ඉංගිරිය' },
    { en: 'Dodangoda', si: 'දොඩම්ගොඩ' },
    { en: 'Payagala', si: 'පයාගල' },
    { en: 'Maggona', si: 'මග්ගොන' },
    { en: 'Dharga Town', si: 'දර්ගා නගරය' },
    { en: 'Walallawita', si: 'වලල්ලාවිට' },
    { en: 'Palindanuwara', si: 'පාලින්දනුවර' },
    { en: 'Meegahatenna', si: 'මීගහතැන්න' }
  ],
  'Kandy': [
    { en: 'Kandy', si: 'මහනුවර' },
    { en: 'Gampola', si: 'ගම්පොළ' },
    { en: 'Nawalapitiya', si: 'නාවලපිටිය' },
    { en: 'Wattegama', si: 'වත්තේගම' },
    { en: 'Kadugannawa', si: 'කඩුගන්නාව' },
    { en: 'Peradeniya', si: 'පේරාදෙණිය' },
    { en: 'Katugastota', si: 'කටුගස්තොට' },
    { en: 'Pilimathalawa', si: 'පිළිමතලාව' },
    { en: 'Gelioya', si: 'ගෙලිඔය' },
    { en: 'Akurana', si: 'අකුරණ' },
    { en: 'Digana', si: 'දිගන' },
    { en: 'Kundasale', si: 'කුණ්ඩසාලේ' },
    { en: 'Teldeniya', si: 'තෙල්දෙණිය' },
    { en: 'Menikhinna', si: 'මැණික්හින්න' },
    { en: 'Pussellawa', si: 'පුස්සැල්ලාව' },
    { en: 'Galagedara', si: 'ගලගෙදර' },
    { en: 'Madawala', si: 'මඩවල' },
    { en: 'Alawatugoda', si: 'අලවතුගොඩ' },
    { en: 'Hasalaka', si: 'හසලක' },
    { en: 'Pujapitiya', si: 'පූජාපිටිය' },
    { en: 'Ududumbara', si: 'උඩුදුම්බර' },
    { en: 'Galaha', si: 'ගලහ' },
    { en: 'Panwila', si: 'පන්විල' }
  ],
  'Matale': [
    { en: 'Matale', si: 'මාතලේ' },
    { en: 'Dambulla', si: 'දඹුල්ල' },
    { en: 'Galewela', si: 'ගලේවෙල' },
    { en: 'Rattota', si: 'රත්තොට' },
    { en: 'Ukuwela', si: 'උකුවෙල' },
    { en: 'Naula', si: 'නාවුල' },
    { en: 'Sigiriya', si: 'සීගිරිය' },
    { en: 'Palapathwela', si: 'පලපත්වල' },
    { en: 'Yatawatta', si: 'යටවත්ත' },
    { en: 'Laggala', si: 'ලග්ගල' },
    { en: 'Wilgamuwa', si: 'විල්ගමුව' },
    { en: 'Pallepola', si: 'පල්ලේපොල' },
    { en: 'Elkaduwa', si: 'ඇල්කඩුව' }
  ],
  'Nuwara Eliya': [
    { en: 'Nuwara Eliya', si: 'නුවරඑළිය' },
    { en: 'Hatton - Dikoya', si: 'හැටන් - දික්ඔය' },
    { en: 'Talawakele - Lindula', si: 'තලවකැලේ - ලිඳුල' },
    { en: 'Maskeliya', si: 'මස්කෙළිය' },
    { en: 'Bogawantalawa', si: 'බොගවන්තලාව' },
    { en: 'Kotagala', si: 'කොටගල' },
    { en: 'Ginigathena', si: 'ගිනිගත්හේන' },
    { en: 'Norwood', si: 'නෝර්වුඩ්' },
    { en: 'Agarapathana', si: 'අගරපතන' },
    { en: 'Nanu Oya', si: 'නානුඔය' },
    { en: 'Ramboda', si: 'රම්බොඩ' },
    { en: 'Pundaluoya', si: 'පුඬළුඔය' },
    { en: 'Hanguranketha', si: 'හඟුරන්කෙත' },
    { en: 'Walapane', si: 'වලපනේ' },
    { en: 'Ambagamuwa', si: 'අඹගමුව' }
  ],
  'Galle': [
    { en: 'Galle', si: 'ගාල්ල' },
    { en: 'Ambalangoda', si: 'අම්බලන්ගොඩ' },
    { en: 'Hikkaduwa', si: 'හික්කඩුව' },
    { en: 'Elpitiya', si: 'ඇල්පිටිය' },
    { en: 'Baddegama', si: 'බද්දේගම' },
    { en: 'Balapitiya', si: 'බලපිටිය' },
    { en: 'Bentota', si: 'බෙන්තොට' },
    { en: 'Ahungalla', si: 'අහුන්ගල්ල' },
    { en: 'Koggala', si: 'කොග්ගල' },
    { en: 'Habaraduwa', si: 'හබරාදුව' },
    { en: 'Ahangama', si: 'අහංගම' },
    { en: 'Karandeniya', si: 'කරන්දෙණිය' },
    { en: 'Yakkalamulla', si: 'යක්කලමුල්ල' },
    { en: 'Udugama', si: 'උඩුගම' },
    { en: 'Neluwa', si: 'නෙළුව' },
    { en: 'Imaduwa', si: 'ඉමදූව' },
    { en: 'Wanduramba', si: 'වඳුරඹ' },
    { en: 'Rathgama', si: 'රත්ගම' },
    { en: 'Boossa', si: 'බූස්ස' },
    { en: 'Karapitiya', si: 'කරාපිටිය' },
    { en: 'Uragasmanhandiya', si: 'උරගස්මංහන්දිය' }
  ],
  'Matara': [
    { en: 'Matara', si: 'මාතර' },
    { en: 'Weligama', si: 'වැලිගම' },
    { en: 'Akuressa', si: 'අකුරැස්ස' },
    { en: 'Dikwella', si: 'දික්වැල්ල' },
    { en: 'Hakmana', si: 'හක්මන' },
    { en: 'Deniyaya', si: 'දෙනියාය' },
    { en: 'Kamburupitiya', si: 'කඹුරුපිටිය' },
    { en: 'Mirissa', si: 'මිරිස්ස' },
    { en: 'Morawaka', si: 'මොරවක' },
    { en: 'Devinuwara', si: 'දෙවිනුවර' },
    { en: 'Pitabeddara', si: 'පිටබැද්දර' },
    { en: 'Malimbada', si: 'මාලිම්බඩ' },
    { en: 'Thihagoda', si: 'තිහගොඩ' },
    { en: 'Pasgoda', si: 'පස්ගොඩ' },
    { en: 'Mulatiyana', si: 'මුලටියන' },
    { en: 'Kirinda Puhulwella', si: 'කිරින්ද පුහුල්වැල්ල' },
    { en: 'Kamburugamuwa', si: 'කඹුරුගමුව' },
    { en: 'Urubokka', si: 'ඌරුබොක්ක' },
    { en: 'Makandura', si: 'මාකඳුර' },
    { en: 'Welipitiya', si: 'වැලිපිටිය' },
    { en: 'Gandara', si: 'ගන්දර' },
    { en: 'Kekanadurra', si: 'කැකණදුර' }
  ],
  'Hambantota': [
    { en: 'Hambantota', si: 'හම්බන්තොට' },
    { en: 'Tangalle', si: 'තංගල්ල' },
    { en: 'Ambalantota', si: 'අම්බලන්තොට' },
    { en: 'Tissamaharama', si: 'තිස්සමහාරාමය' },
    { en: 'Beliatta', si: 'බෙලිඅත්ත' },
    { en: 'Weeraketiya', si: 'වීරකැටිය' },
    { en: 'Walasmulla', si: 'වලස්මුල්ල' },
    { en: 'Suriyawewa', si: 'සූරියවැව' },
    { en: 'Angunakolapelessa', si: 'අඟුණකොළපැලැස්ස' },
    { en: 'Middeniya', si: 'මිද්දෙනිය' },
    { en: 'Katuwana', si: 'කටුවන' },
    { en: 'Lunugamvehera', si: 'ලුනුගම්වෙහෙර' },
    { en: 'Ranna', si: 'රන්න' },
    { en: 'Hungama', si: 'හුංගම' },
    { en: 'Kirinda', si: 'කිරින්ද' }
  ],
  'Jaffna': [
    { en: 'Jaffna', si: 'යාපනය' },
    { en: 'Point Pedro', si: 'පේදුරුතුඩුව' },
    { en: 'Valvettithurai', si: 'වෙල්වෙටිතුරෙයි' },
    { en: 'Chavakachcheri', si: 'චාවකච්චේරි' },
    { en: 'Chunnakam', si: 'චුන්නාකම්' },
    { en: 'Kankesanthurai', si: 'කන්කසන්තුරෙයි' },
    { en: 'Nallur', si: 'නල්ලූර්' },
    { en: 'Kopay', si: 'කෝපායි' },
    { en: 'Manipay', si: 'මානිපායි' },
    { en: 'Tellippalai', si: 'තෙල්ලිපලෙයි' },
    { en: 'Uduvil', si: 'උඩුවිල්' },
    { en: 'Karaveddy', si: 'කරවෙඩ්ඩි' },
    { en: 'Sandilipay', si: 'සන්දිලිපායි' },
    { en: 'Kayts', si: 'කයිට්ස්' },
    { en: 'Delft', si: 'ඩෙල්ෆ්ට්' },
    { en: 'Velanai', si: 'වේලනෙයි' },
    { en: 'Karainagar', si: 'කාරෙයිනගර්' },
    { en: 'Maruthankerney', si: 'මරුදන්කේනි' }
  ],
  'Kilinochchi': [
    { en: 'Kilinochchi', si: 'කිළිනොච්චිය' },
    { en: 'Paranthan', si: 'පරන්තන්' },
    { en: 'Pooneryn', si: 'පූනකරි' },
    { en: 'Pallai', si: 'පලෙයි' },
    { en: 'Kandawalai', si: 'කණ්ඩාවලෙයි' },
    { en: 'Akkarayankulam', si: 'අක්කරායන්කුලම්' },
    { en: 'Dharmapuram', si: 'ධර්මපුරම්' },
    { en: 'Elephant Pass', si: 'අලිමංකඩ' },
    { en: 'Uruthirapuram', si: 'උරුතිරපුරම්' }
  ],
  'Mannar': [
    { en: 'Mannar', si: 'මන්නාරම' },
    { en: 'Thalaimannar', si: 'තලෙයිමන්නාරම' },
    { en: 'Pesalai', si: 'පේසාලෙයි' },
    { en: 'Murunkan', si: 'මුරුන්කන්' },
    { en: 'Nanaddan', si: 'නානාට්ටාන්' },
    { en: 'Madhu', si: 'මඩු' },
    { en: 'Silawathura', si: 'සිලාවතුර' },
    { en: 'Adampan', si: 'අඩම්පන්' },
    { en: 'Vidattaltivu', si: 'විදත්තල්තීව්' },
    { en: 'Manthei', si: 'මාන්තෙයි' }
  ],
  'Vavuniya': [
    { en: 'Vavuniya', si: 'වවුනියාව' },
    { en: 'Cheddikulam', si: 'චෙඩ්ඩිකුලම්' },
    { en: 'Nedunkeni', si: 'නෙඩුන්කේනි' },
    { en: 'Omanthai', si: 'ඕමන්ත' },
    { en: 'Kanagarayankulam', si: 'කනගරායන්කුලම්' },
    { en: 'Poovarasankulam', si: 'පූවරසන්කුලම්' },
    { en: 'Mamaduwa', si: 'මාමඩුව' },
    { en: 'Pampaimadu', si: 'පම්පෙයිමඩු' },
    { en: 'Ulukkulam', si: 'උලුක්කුලම්' },
    { en: 'Neriyakulam', si: 'නෙරියකුලම්' }
  ],
  'Mullaitivu': [
    { en: 'Mullaitivu', si: 'මුලතිව්' },
    { en: 'Puthukkudiyiruppu', si: 'පුදුකුඩිඉරිප්පු' },
    { en: 'Mankulam', si: 'මාන්කුලම්' },
    { en: 'Oddusuddan', si: 'ඔඩ්ඩුසුඩාන්' },
    { en: 'Mallavi', si: 'මල්ලාවි' },
    { en: 'Thunukkai', si: 'තුනුක්කායි' },
    { en: 'Welioya', si: 'වැලිඔය' },
    { en: 'Mulliyawalai', si: 'මුල්ලියාවලෙයි' },
    { en: 'Alampil', si: 'අලම්පිල්' },
    { en: 'Vellamullivaikkal', si: 'වෙල්ලමුල්ලිවයික්කාල්' }
  ],
  'Batticaloa': [
    { en: 'Batticaloa', si: 'මඩකලපුව' },
    { en: 'Eravur', si: 'එරාවුර්' },
    { en: 'Kattankudy', si: 'කාත්තන්කුඩි' },
    { en: 'Valaichchenai', si: 'වාලච්චේන' },
    { en: 'Kaluwanchikudy', si: 'කලවංචිකුඩි' },
    { en: 'Chenkalady', si: 'චෙන්කලඩි' },
    { en: 'Oddamavadi', si: 'ඕඩමාවඩි' },
    { en: 'Pasikuda', si: 'පාසිකුඩා' },
    { en: 'Kalkudah', si: 'කල්කුඩා' },
    { en: 'Vakarai', si: 'වාකරේ' },
    { en: 'Kiran', si: 'කිරාන්' },
    { en: 'Arayampathy', si: 'ආරයම්පති' },
    { en: 'Kokkadichcholai', si: 'කොක්කඩිචෝලෙයි' },
    { en: 'Vavunathivu', si: 'වවුනතිව්' },
    { en: 'Vantharumoolai', si: 'වන්දාරමුල්ල' }
  ],
  'Ampara': [
    { en: 'Ampara', si: 'අම්පාර' },
    { en: 'Kalmunai', si: 'කල්මුණේ' },
    { en: 'Akkaraipattu', si: 'අක්කරපත්තුව' },
    { en: 'Sammanthurai', si: 'සමන්තුරේ' },
    { en: 'Pottuvil', si: 'පොතුවිල්' },
    { en: 'Arugam Bay', si: 'ආරුගම්බේ' },
    { en: 'Dehiattakandiya', si: 'දෙහිඅත්තකණ්ඩිය' },
    { en: 'Padiyathalawa', si: 'පදියතලාව' },
    { en: 'Mahaoya', si: 'මහාඔය' },
    { en: 'Uhana', si: 'උහන' },
    { en: 'Damana', si: 'දමන' },
    { en: 'Nintavur', si: 'නින්දවූර්' },
    { en: 'Thirukkovil', si: 'තිරුක්කෝවිල්' },
    { en: 'Sainthamaruthu', si: 'සයින්දමරුදු' },
    { en: 'Addalaichenai', si: 'අඩ්ඩාලච්චේන' },
    { en: 'Irakkamam', si: 'ඉරක්කාමම්' },
    { en: 'Lahugala', si: 'ලාහුගල' }
  ],
  'Trincomalee': [
    { en: 'Trincomalee', si: 'ත්‍රිකුණාමලය' },
    { en: 'Kinniya', si: 'කින්නියා' },
    { en: 'Muttur', si: 'මුතූර්' },
    { en: 'Kantale', si: 'කන්තලේ' },
    { en: 'Nilaveli', si: 'නිලාවේලි' },
    { en: 'Pulmoddai', si: 'පුල්මුඩේ' },
    { en: 'Kuchchaveli', si: 'කුච්චවේලි' },
    { en: 'China Bay', si: 'චීන වරාය' },
    { en: 'Seruwawila', si: 'සේරුවාවිල' },
    { en: 'Morawewa', si: 'මොරවැව' },
    { en: 'Gomarankadawala', si: 'ගෝමරන්කඩවල' },
    { en: 'Padavi Sri Pura', si: 'පදවි ශ්‍රී පුර' },
    { en: 'Thampalakamam', si: 'තම්පලගාමම්' },
    { en: 'Verugal', si: 'වෙරුගල්' }
  ],
  'Kurunegala': [
    { en: 'Kurunegala', si: 'කුරුණෑගල' },
    { en: 'Kuliyapitiya', si: 'කුලියාපිටිය' },
    { en: 'Polgahawela', si: 'පොල්ගහවෙල' },
    { en: 'Pannala', si: 'පන්නල' },
    { en: 'Narammala', si: 'නාරම්මල' },
    { en: 'Wariyapola', si: 'වාරියපොල' },
    { en: 'Nikaweratiya', si: 'නිකවැරටිය' },
    { en: 'Maho', si: 'මහව' },
    { en: 'Galgamuwa', si: 'ගල්ගමුව' },
    { en: 'Ibbagamuwa', si: 'ඉබ්බාගමුව' },
    { en: 'Mawathagama', si: 'මාවතගම' },
    { en: 'Bingiriya', si: 'බිංගිරිය' },
    { en: 'Alawwa', si: 'අලව්ව' },
    { en: 'Giriulla', si: 'ගිරියුල්ල' },
    { en: 'Hettipola', si: 'හෙට්ටිපොල' },
    { en: 'Panduwasnuwara', si: 'පඬුවස්නුවර' },
    { en: 'Dodangaslanda', si: 'දොඩම්ගස්ලන්ද' },
    { en: 'Udubaddawa', si: 'උඩුබද්දාව' }
  ],
  'Puttalam': [
    { en: 'Puttalam', si: 'පුත්තලම' },
    { en: 'Chilaw', si: 'හලාවත' },
    { en: 'Wennappuwa', si: 'වෙන්නප්පුව' },
    { en: 'Nattandiya', si: 'නාත්තන්ඩිය' },
    { en: 'Marawila', si: 'මාරවිල' },
    { en: 'Dankotuwa', si: 'දංකොටුව' },
    { en: 'Kalpitiya', si: 'කල්පිටිය' },
    { en: 'Anamaduwa', si: 'ආණමඩුව' },
    { en: 'Madampe', si: 'මාදම්පේ' },
    { en: 'Mundalama', si: 'මුන්දලම' },
    { en: 'Karuwalagaswewa', si: 'කරුවලගස්වැව' },
    { en: 'Mahawewa', si: 'මහවැව' },
    { en: 'Pallama', si: 'පල්ලම' },
    { en: 'Wanathavilluwa', si: 'වනාතවිල්ලුව' },
    { en: 'Nawagattegama', si: 'නවගත්තේගම' }
  ],
  'Anuradhapura': [
    { en: 'Anuradhapura', si: 'අනුරාධපුරය' },
    { en: 'Kekirawa', si: 'කැකිරාව' },
    { en: 'Medawachchiya', si: 'මැදවච්චිය' },
    { en: 'Tambuttegama', si: 'තඹුත්තේගම' },
    { en: 'Eppawala', si: 'එප්පාවල' },
    { en: 'Nochchiyagama', si: 'නොච්චියාගම' },
    { en: 'Talawa', si: 'තලාව' },
    { en: 'Mihintale', si: 'මිහින්තලේ' },
    { en: 'Galenbindunuwewa', si: 'ගලෙන්බිඳුණුවැව' },
    { en: 'Padaviya', si: 'පදවිය' },
    { en: 'Kahatagasdigiliya', si: 'කහටගස්දිගිලිය' },
    { en: 'Horowpathana', si: 'හොරොව්පොතාන' },
    { en: 'Kebithigollewa', si: 'කැබිතිගොල්ලෑව' },
    { en: 'Rambewa', si: 'රඹෑව' },
    { en: 'Tirappane', si: 'තිරප්පනේ' },
    { en: 'Rajanganaya', si: 'රාජාංගනය' },
    { en: 'Ipalogama', si: 'ඉපලෝගම' },
    { en: 'Palugaswewa', si: 'පලුගස්වැව' },
    { en: 'Galnewa', si: 'ගල්නෑව' },
    { en: 'Habarana', si: 'හබරණ' }
  ],
  'Polonnaruwa': [
    { en: 'Polonnaruwa', si: 'පොළොන්නරුව' },
    { en: 'Kaduruwela', si: 'කදුරුවෙල' },
    { en: 'Hingurakgoda', si: 'හිඟුරක්ගොඩ' },
    { en: 'Medirigiriya', si: 'මැදිරිගිරිය' },
    { en: 'Minneriya', si: 'මින්නේරිය' },
    { en: 'Manampitiya', si: 'මනම්පිටිය' },
    { en: 'Welikanda', si: 'වැලික්කන්ද' },
    { en: 'Aralaganwila', si: 'අරලගංවිල' },
    { en: 'Bakamuna', si: 'බකමූණ' },
    { en: 'Dimbulagala', si: 'දිඹුලාගල' },
    { en: 'Elahera', si: 'ඇලහැර' },
    { en: 'Giritale', si: 'ගිරිතලේ' },
    { en: 'Lankapura', si: 'ලංකාපුර' },
    { en: 'Diyabeduma', si: 'දියබෙදුම' },
    { en: 'Pulastigama', si: 'පුලස්තිගම' },
    { en: 'Siripura', si: 'සිරිපුර' }
  ],
  'Badulla': [
    { en: 'Badulla', si: 'බදුල්ල' },
    { en: 'Bandarawela', si: 'බණ්ඩාරවෙල' },
    { en: 'Haputale', si: 'හපුතලේ' },
    { en: 'Mahiyanganaya', si: 'මහියංගනය' },
    { en: 'Welimada', si: 'වැලිමඩ' },
    { en: 'Ella', si: 'ඇල්ල' },
    { en: 'Hali Ela', si: 'හාලිඇල' },
    { en: 'Diyatalawa', si: 'දියතලාව' },
    { en: 'Passara', si: 'පස්සර' },
    { en: 'Lunugala', si: 'ලුනුගල' },
    { en: 'Haldummulla', si: 'හල්දුම්මුල්ල' },
    { en: 'Uva Paranagama', si: 'ඌව පරණගම' },
    { en: 'Meegahakivula', si: 'මීගහකිවුල' },
    { en: 'Kandaketiya', si: 'කන්දකැටිය' },
    { en: 'Soranathota', si: 'සොරණාතොට' },
    { en: 'Rideemaliyadda', si: 'රිදීමාලියද්ද' }
  ],
  'Monaragala': [
    { en: 'Monaragala', si: 'මොනරාගල' },
    { en: 'Wellawaya', si: 'වැල්ලවාය' },
    { en: 'Bibile', si: 'බිබිල' },
    { en: 'Buttala', si: 'බුත්තල' },
    { en: 'Kataragama', si: 'කතරගම' },
    { en: 'Thanamalwila', si: 'තණමල්විල' },
    { en: 'Siyambalanduwa', si: 'සියඹලාණ්ඩුව' },
    { en: 'Badalkumbura', si: 'බඩල්කුඹුර' },
    { en: 'Sevanagala', si: 'සෙවනගල' },
    { en: 'Medagama', si: 'මැදගම' },
    { en: 'Madulla', si: 'මඩුල්ල' }
  ],
  'Ratnapura': [
    { en: 'Ratnapura', si: 'රත්නපුර' },
    { en: 'Balangoda', si: 'බළන්ගොඩ' },
    { en: 'Embilipitiya', si: 'ඇඹිලිපිටිය' },
    { en: 'Pelmadulla', si: 'පැල්මඩුල්ල' },
    { en: 'Eheliyagoda', si: 'ඇහැලියගොඩ' },
    { en: 'Kuruwita', si: 'කුරුවිට' },
    { en: 'Kahawatta', si: 'කහවත්ත' },
    { en: 'Rakwana', si: 'රක්වාන' },
    { en: 'Nivithigala', si: 'නිවිතිගල' },
    { en: 'Kalawana', si: 'කලවාන' },
    { en: 'Godakawela', si: 'ගොඩකවෙල' },
    { en: 'Opanayaka', si: 'ඕපනායක' },
    { en: 'Ayagama', si: 'අයගම' },
    { en: 'Kolonna', si: 'කොලොන්න' },
    { en: 'Weligepola', si: 'වැලිගෙපොළ' },
    { en: 'Elapatha', si: 'ඇලපාත' }
  ],
  'Kegalle': [
    { en: 'Kegalle', si: 'කෑගල්ල' },
    { en: 'Mawanella', si: 'මාවනැල්ල' },
    { en: 'Rambukkana', si: 'රඹුක්කන' },
    { en: 'Warakapola', si: 'වරකාපොල' },
    { en: 'Ruwanwella', si: 'රුවන්වැල්ල' },
    { en: 'Yatiyantota', si: 'යටියන්තොට' },
    { en: 'Dehiowita', si: 'දෙහිඕවිට' },
    { en: 'Deraniyagala', si: 'දැරණියගල' },
    { en: 'Galigamuwa', si: 'ගලිගමුව' },
    { en: 'Aranayaka', si: 'අරණායක' },
    { en: 'Bulathkohupitiya', si: 'බුලත්කොහුපිටිය' },
    { en: 'Kitulgala', si: 'කිතුල්ගල' }
  ]
};

// 50 default categories
const DEFAULT_DATABASE_CATEGORIES = [
  { nameEn: 'Electrician Services', nameSi: 'විදුලි කාර්මික සේවා' },
  { nameEn: 'Plumbing & Water Lines', nameSi: 'නළ එළීමේ සහ ජලනල සේවා' },
  { nameEn: 'Carpentry & Woodwork', nameSi: 'වඩු කාර්මික සේවා' },
  { nameEn: 'AC Repair & Service', nameSi: 'ඒසී (A/C) අලුත්වැඩියාව සහ නඩත්තුව' },
  { nameEn: 'Masonry & Construction', nameSi: 'මේසන් සහ ගොඩනැගිලි වැඩ' },
  { nameEn: 'House Painting', nameSi: 'තීන්ත ආලේපනය' },
  { nameEn: 'Tile Laying & Flooring', nameSi: 'ටයිල් එළීම සහ පොළොව සැකසීම' },
  { nameEn: 'Gardening & Landscaping', nameSi: 'ගෙවතු අලංකරණය සහ නඩත්තුව' },
  { nameEn: 'House Deep Cleaning', nameSi: 'නිවාස පිරිසිදු කිරීම' },
  { nameEn: 'Solar Panel Installation', nameSi: 'සෞර ශක්ති (Solar) පද්ධති සවිකිරීම' },
  { nameEn: 'CCTV & Security Systems', nameSi: 'CCTV සහ ආරක්ෂක කැමරා' },
  { nameEn: 'Appliance Repair', nameSi: 'ගෘහ උපකරණ අලුත්වැඩියාව' },
  { nameEn: 'Roof Repair & Waterproofing', nameSi: 'වහල අලුත්වැඩියාව සහ කාන්දුවීම්' },
  { nameEn: 'Pest Control', nameSi: 'කෘමීන් සහ පළිබෝධ පාලනය' },
  { nameEn: 'Mobile Vehicle Mechanics', nameSi: 'වාහන අලුත්වැඩියාව සහ සේවා' },
  { nameEn: 'Washing Machine Repair', nameSi: 'රෙදි සෝදන යන්ත්‍ර අලුත්වැඩියාව' },
  { nameEn: 'Refrigerator Repair', nameSi: 'ශීතකරණ අලුත්වැඩියාව' },
  { nameEn: 'Aluminum Fabrication', nameSi: 'ඇලුමිනියම් පද්ධති සවිකිරීම' },
  { nameEn: 'Welding & Ironworks', nameSi: 'වෙල්ඩින් සහ යකඩ වැඩ' },
  { nameEn: 'Interior Designing', nameSi: 'අභ්‍යන්තර අලංකරණය (Interior Design)' },
  { nameEn: 'Water Tank Cleaning', nameSi: 'වතුර ටැංකි පිරිසිදු කිරීම' },
  { nameEn: 'Lawn Mowing & Yard Clean', nameSi: 'තණකොළ කැපීම සහ සුද්ධ කිරීම' },
  { nameEn: 'Gutter Cleaning', nameSi: 'පීලි (Gutters) සුද්ධ කිරීම' },
  { nameEn: 'Furniture Polish & Repair', nameSi: 'ගෘහ භාණ්ඩ අලුත්වැඩියාව සහ පොලිෂ්' },
  { nameEn: 'Locksmith & Key Service', nameSi: 'යතුරු සාදන්නන් සහ උගුල් ඇරීම' },
  { nameEn: 'Emergency Electrical Fix', nameSi: 'හදිසි විදුලි පද්ධති පරීක්ෂාව' },
  { nameEn: 'Septic Tank Cleaning', nameSi: 'සෙප්ටික් ටැංකි සුද්ධ කිරීම' },
  { nameEn: 'Kitchen Hood Cleaning', nameSi: 'දුම් කවුළු සහ කුස්සි පෝරණු සුද්ධය' },
  { nameEn: 'Swimming Pool Maintenance', nameSi: 'පිහිනුම් තටාක නඩත්තුව' },
  { nameEn: 'House Moving & Transport', nameSi: 'නිවාස ගෘහභාණ්ඩ ප්‍රවාහනය' },
  { nameEn: 'Sofa & Cushion Washing', nameSi: 'සෝෆා සහ කුෂන් පිරිසිදු කිරීම' },
  { nameEn: 'Carpet Deep Wash', nameSi: 'කාපට් හෝදනය සහ පිරිසිදුව' },
  { nameEn: 'Wooden Floor Polishing', nameSi: 'ලී පොළොව පොලිෂ් කිරීම' },
  { nameEn: 'Glass & Window Cleaning', nameSi: 'වීදුරු සහ ජනෙල් පිරිසිදු කිරීම' },
  { nameEn: 'Generator Maintenance', nameSi: 'ජෙනරේටර් (Generator) අලුත්වැඩියාව' },
  { nameEn: 'Solar Water Heater Repair', nameSi: 'සූරිය උණු වතුර (Solar Heater) පද්ධති' },
  { nameEn: 'Water Heater Fix', nameSi: 'ගීසර් (Geyser) අලුත්වැඩියාව' },
  { nameEn: 'Smart Home Automation', nameSi: 'ස්මාර්ට් හෝම් (Smart Home) සැකසීම' },
  { nameEn: 'Wallpaper Installation', nameSi: 'වෝල් පේපර් (Wallpaper) ඇලවීම' },
  { nameEn: 'Curtain Rods & Blind Fix', nameSi: 'තිර රෙදි (Curtains) සවිකිරීම' },
  { nameEn: 'TV Mounting & Setup', nameSi: 'ටීවී (TV) බිත්තියේ සවිකිරීම' },
  { nameEn: 'Sound System Setup', nameSi: 'ශබ්ද පද්ධති (Sound System) සැකසුම්' },
  { nameEn: 'Water Pump Repair', nameSi: 'වතුර මෝටර් (Water Pump) අලුත්වැඩියාව' },
  { nameEn: 'Disinfection & Sanitization', nameSi: 'විෂබීජ හරණය සහ ධූමකරණය' },
  { nameEn: 'Door & Window Hinges Fix', nameSi: 'දොර සහ ජනෙල් සගල (Hinges) අලුත්වැඩියාව' },
  { nameEn: 'Gas Stove & Oven Repair', nameSi: 'ගෑස් ලිප් (Gas Stove) අලුත්වැඩියාව' },
  { nameEn: 'Wall Art & Mirror Hanging', nameSi: 'ඡායාරූප සහ චිත්‍ර රාමු සවිකිරීම' },
  { nameEn: 'Microwave Oven Repair', nameSi: 'මයික්‍රෝවේව් (Microwave) අලුත්වැඩියාව' },
  { nameEn: 'Mosquito Net Installation', nameSi: 'මදුරු ජාලා (Mosquito Net) සවිකිරීම' },
  { nameEn: 'Roof Truss & Battens Work', nameSi: 'වහල පරාල සහ ලෑලි සේවාවන්' }
];

// Smart auto-detection of Lucide icon from English or Sinhala category names
function autoDetectIcon(nameEn = '', nameSi = '') {
  const text = `${nameEn} ${nameSi}`.toLowerCase();

  if (text.includes('solar') || text.includes('sun') || text.includes('energy') || text.includes('සූර්ය') || text.includes('සෞර')) return 'Sun';
  if (text.includes('electr') || text.includes('power') || text.includes('wire') || text.includes('light') || text.includes('generator') || text.includes('විදුලි') || text.includes('වයරින්')) return 'Zap';
  if (text.includes('plumb') || text.includes('water') || text.includes('pipe') || text.includes('tap') || text.includes('tank') || text.includes('pump') || text.includes('drain') || text.includes('ජල') || text.includes('නළ') || text.includes('බට') || text.includes('මෝටර්')) return 'Droplets';
  if (text.includes('paint') || text.includes('color') || text.includes('wall') || text.includes('polish') || text.includes('varnish') || text.includes('තීන්ත') || text.includes('පාට')) return 'Paintbrush';
  if (text.includes('ac') || text.includes('air') || text.includes('cool') || text.includes('fan') || text.includes('ventil') || text.includes('blower') || text.includes('ඒසී') || text.includes('වායු')) return 'Wind';
  if (text.includes('fridge') || text.includes('refriger') || text.includes('freezer') || text.includes('ice') || text.includes('ශීතකරණ')) return 'Snowflake';
  if (text.includes('tile') || text.includes('mason') || text.includes('floor') || text.includes('paving') || text.includes('slab') || text.includes('brick') || text.includes('ටයිල්') || text.includes('මේසන්') || text.includes('පොළොව') || text.includes('ගඩොල්')) return 'Grid';
  if (text.includes('carpenter') || text.includes('wood') || text.includes('roof') || text.includes('ceiling') || text.includes('furniture') || text.includes('door') || text.includes('වඩු') || text.includes('ලී') || text.includes('වහල') || text.includes('සිවිලිං') || text.includes('ගෘහ භාණ්ඩ')) return 'Hammer';
  if (text.includes('weld') || text.includes('iron') || text.includes('steel') || text.includes('metal') || text.includes('aluminum') || text.includes('gas') || text.includes('stove') || text.includes('oven') || text.includes('වෙල්ඩින්') || text.includes('යකඩ') || text.includes('ඇලුමිනියම්') || text.includes('ගෑස්')) return 'Flame';
  if (text.includes('clean') || text.includes('wash') || text.includes('dust') || text.includes('deep') || text.includes('carpet') || text.includes('sofa') || text.includes('sweep') || text.includes('පිරිසිදු') || text.includes('සෝදන') || text.includes('කාපට්') || text.includes('කුෂන්')) return 'Sparkles';
  if (text.includes('cctv') || text.includes('camera') || text.includes('security') || text.includes('surveillance') || text.includes('කැමරා') || text.includes('ආරක්ෂක')) return 'Camera';
  if (text.includes('garden') || text.includes('tree') || text.includes('landscape') || text.includes('grass') || text.includes('lawn') || text.includes('plant') || text.includes('ගෙවතු') || text.includes('තණකොළ') || text.includes('ගස්')) return 'Trees';
  if (text.includes('pest') || text.includes('bug') || text.includes('termite') || text.includes('insect') || text.includes('mosquito') || text.includes('පළිබෝධ') || text.includes('කෘමීන්') || text.includes('වේයන්') || text.includes('මදුරු')) return 'Bug';
  if (text.includes('car') || text.includes('vehicle') || text.includes('auto') || text.includes('transport') || text.includes('moving') || text.includes('mechanic') || text.includes('garage') || text.includes('වාහන') || text.includes('ප්‍රවාහන') || text.includes('ගැරාජ්')) return 'Truck';
  if (text.includes('tv') || text.includes('television') || text.includes('display') || text.includes('screen') || text.includes('ටීවී')) return 'Tv';
  if (text.includes('key') || text.includes('lock') || text.includes('safe') || text.includes('යතුරු') || text.includes('අගුල්')) return 'Key';
  if (text.includes('it') || text.includes('computer') || text.includes('laptop') || text.includes('smart') || text.includes('wifi') || text.includes('network') || text.includes('පරිගණක') || text.includes('කම්පියුටර්') || text.includes('ස්මාර්ට්')) return 'Cpu';
  if (text.includes('sound') || text.includes('audio') || text.includes('speaker') || text.includes('music') || text.includes('ශබ්ද') || text.includes('ස්පීකර්')) return 'Volume2';
  if (text.includes('curtain') || text.includes('blind') || text.includes('cloth') || text.includes('tailor') || text.includes('sewing') || text.includes('රෙදි') || text.includes('තිර') || text.includes('මැහුම්')) return 'Shirt';
  if (text.includes('geyser') || text.includes('heater') || text.includes('thermal') || text.includes('ගීසර්') || text.includes('හීටර්')) return 'Thermometer';

  return 'Wrench';
}

// Smart password strength checker (min 8 chars, A-Z, a-z, 0-9, special char)
function checkPasswordStrength(pass = '') {
  const hasMinLength = pass.length >= 8;
  const hasUpper = /[A-Z]/.test(pass);
  const hasLower = /[a-z]/.test(pass);
  const hasNumber = /[0-9]/.test(pass);
  const hasSpecial = /[!@#$%^&*(),.?":{}|<>_\-]/.test(pass);

  let score = 0;
  if (hasMinLength) score++;
  if (hasUpper) score++;
  if (hasLower) score++;
  if (hasNumber) score++;
  if (hasSpecial) score++;

  let label = 'Very Weak';
  let color = 'bg-rose-500';
  let textColor = 'text-rose-600';
  let barWidth = '20%';

  if (score === 5) {
    label = 'Strong Password';
    color = 'bg-emerald-500';
    textColor = 'text-emerald-600';
    barWidth = '100%';
  } else if (score === 4) {
    label = 'Good';
    color = 'bg-teal-500';
    textColor = 'text-teal-600';
    barWidth = '80%';
  } else if (score === 3) {
    label = 'Fair';
    color = 'bg-amber-500';
    textColor = 'text-amber-600';
    barWidth = '60%';
  } else if (score === 2) {
    label = 'Weak';
    color = 'bg-orange-500';
    textColor = 'text-orange-600';
    barWidth = '40%';
  }

  const isStrong = hasMinLength && hasUpper && hasLower && hasNumber && hasSpecial;

  return {
    score,
    hasMinLength,
    hasUpper,
    hasLower,
    hasNumber,
    hasSpecial,
    isStrong,
    label,
    color,
    textColor,
    barWidth
  };
}

export default function AddProviderModal({ 
  isOpen, 
  onClose, 
  categories = [], 
  onProviderCreated 
}) {
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [category, setCategory] = useState('');
  
  // Custom Category States
  const [customCategoryEn, setCustomCategoryEn] = useState('');
  const [customCategorySi, setCustomCategorySi] = useState('');
  const [customCategoryIcon, setCustomCategoryIcon] = useState('Wrench');
  const [isManualIconSelected, setIsManualIconSelected] = useState(false);

  const [experienceYears, setExperienceYears] = useState('3');
  const [workingRadius, setWorkingRadius] = useState('25');
  
  // District & City States with bilingual mapping
  const [district, setDistrict] = useState('Colombo');
  const [city, setCity] = useState(SRI_LANKA_DISTRICT_CITIES_BILINGUAL['Colombo'][0].en);
  const [customCity, setCustomCity] = useState('');

  const [address, setAddress] = useState('');
  const [nicNumber, setNicNumber] = useState('');
  const [isAutoApprove, setIsAutoApprove] = useState(true);

  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState(null);
  const [successMsg, setSuccessMsg] = useState(null);

  // Auto-detect icon whenever custom English or Sinhala category names change
  useEffect(() => {
    if (!isManualIconSelected) {
      const detected = autoDetectIcon(customCategoryEn, customCategorySi);
      setCustomCategoryIcon(detected);
    }
  }, [customCategoryEn, customCategorySi, isManualIconSelected]);

  // Handle District Change & automatically update city options
  const handleDistrictChange = (newDistrict) => {
    setDistrict(newDistrict);
    const availableCities = SRI_LANKA_DISTRICT_CITIES_BILINGUAL[newDistrict] || [];
    setCity(availableCities[0]?.en || newDistrict);
    setCustomCity('');
  };

  if (!isOpen) return null;

  // Build the list of categories from DB props or fallback list
  const categoryList = categories.length > 0 
    ? categories.map(c => {
        const en = c.nameEn || c.name_en || (typeof c === 'string' ? c : '');
        const si = c.nameSi || c.name_si || '';
        return {
          value: en || si,
          nameEn: en,
          nameSi: si
        };
      })
    : DEFAULT_DATABASE_CATEGORIES.map(c => ({
        value: c.nameEn,
        nameEn: c.nameEn,
        nameSi: c.nameSi
      }));

  const initialSelectedCategory = category || (categoryList.length > 0 ? categoryList[0].value : '');

  // Helper to generate a guaranteed strong password with all criteria
  const generateStrongPassword = () => {
    const chars = "abcdefghjkmnpqrstuvwxyz";
    const uppers = "ABCDEFGHJKLMNPQRSTUVWXYZ";
    const numbers = "23456789";
    const symbols = "!@#$%^&*";
    
    // Pick guaranteed characters from each category
    let passArr = [
      uppers.charAt(Math.floor(Math.random() * uppers.length)),
      uppers.charAt(Math.floor(Math.random() * uppers.length)),
      chars.charAt(Math.floor(Math.random() * chars.length)),
      chars.charAt(Math.floor(Math.random() * chars.length)),
      chars.charAt(Math.floor(Math.random() * chars.length)),
      numbers.charAt(Math.floor(Math.random() * numbers.length)),
      numbers.charAt(Math.floor(Math.random() * numbers.length)),
      symbols.charAt(Math.floor(Math.random() * symbols.length)),
      symbols.charAt(Math.floor(Math.random() * symbols.length))
    ];
    
    const allPool = chars + uppers + numbers + symbols;
    for (let i = 0; i < 2; i++) {
      passArr.push(allPool.charAt(Math.floor(Math.random() * allPool.length)));
    }
    
    // Shuffle the array
    const strongPass = passArr.sort(() => 0.5 - Math.random()).join('');
    
    setPassword(strongPass);
    setShowPassword(true);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErrorMsg(null);
    setSuccessMsg(null);

    // Form Validations
    if (!fullName.trim()) {
      setErrorMsg('Full name is required.');
      return;
    }
    if (!email.trim() || !email.includes('@')) {
      setErrorMsg('Valid email address is required.');
      return;
    }
    if (!phone.trim()) {
      setErrorMsg('Phone number is required.');
      return;
    }

    // Strict Strong Password Validation
    const pwdStrength = checkPasswordStrength(password.trim());
    if (!pwdStrength.isStrong) {
      setErrorMsg('Please enter a strong password (minimum 8 characters with Uppercase A-Z, Lowercase a-z, Numbers 0-9, and Special symbol @#$).');
      return;
    }

    let finalCategory = category || (categoryList.length > 0 ? categoryList[0].value : 'Electrician Services');

    if (category === 'Other') {
      if (!customCategoryEn.trim()) {
        setErrorMsg('Please enter the English name for the new custom category.');
        return;
      }
      finalCategory = customCategoryEn.trim();

      // Automatically register the new category in the database
      try {
        await createCategoryApi({
          nameEn: customCategoryEn.trim(),
          nameSi: customCategorySi.trim() || customCategoryEn.trim(),
          icon: customCategoryIcon || 'Wrench',
          basePrice: 2500
        });
      } catch (catErr) {
        console.warn('⚠️ Category creation notice:', catErr.message);
      }
    }

    if (!finalCategory) {
      setErrorMsg('Please select or specify a service category.');
      return;
    }

    // Resolve final city value
    const finalCity = city === 'Other' 
      ? (customCity.trim() || district) 
      : (city || SRI_LANKA_DISTRICT_CITIES_BILINGUAL[district]?.[0]?.en || district);

    setLoading(true);

    try {
      const payload = {
        full_name: fullName.trim(),
        email: email.trim().toLowerCase(),
        phone: phone.trim(),
        password: password.trim(),
        service_category: finalCategory,
        experience_years: parseInt(experienceYears) || 1,
        working_radius_km: parseInt(workingRadius) || 20,
        district: district || 'Colombo',
        city: finalCity,
        address: address.trim(),
        nic_number: nicNumber.trim(),
        is_verified: isAutoApprove
      };

      const res = await createProviderApi(payload);

      if (res && res.success) {
        setSuccessMsg(res.message || '🎉 Service provider added successfully!');
        
        if (onProviderCreated) {
          onProviderCreated(res.data);
        }

        // Reset fields after short delay
        setTimeout(() => {
          setFullName('');
          setEmail('');
          setPhone('');
          setPassword('');
          setCustomCategoryEn('');
          setCustomCategorySi('');
          setCustomCategoryIcon('Wrench');
          setIsManualIconSelected(false);
          setDistrict('Colombo');
          setCity(SRI_LANKA_DISTRICT_CITIES_BILINGUAL['Colombo'][0].en);
          setCustomCity('');
          setAddress('');
          setNicNumber('');
          setSuccessMsg(null);
          onClose();
        }, 1500);

      } else {
        setErrorMsg(res?.error || 'Failed to create service provider. Please try again.');
      }
    } catch (err) {
      setErrorMsg(err.message || 'Server error creating provider.');
    } finally {
      setLoading(false);
    }
  };

  const SelectedIconComponent = ICON_MAP[customCategoryIcon] || Wrench;
  const currentDistrictCities = SRI_LANKA_DISTRICT_CITIES_BILINGUAL[district] || [];
  const selectedDistrictObj = SRI_LANKA_DISTRICTS_BILINGUAL.find(d => d.id === district);
  const pwdStrength = checkPasswordStrength(password);

  return createPortal(
    <div className="fixed inset-0 z-[9999] flex items-center justify-center p-4 sm:p-6 bg-slate-900/60 backdrop-blur-sm animate-in fade-in duration-200">
      <div className="relative w-full max-w-2xl max-h-[92vh] bg-white border border-slate-200 rounded-3xl shadow-2xl flex flex-col overflow-hidden animate-in zoom-in-95 duration-200">
        
        {/* Modal Header */}
        <div className="px-6 py-5 bg-gradient-to-r from-slate-900 via-slate-800 to-slate-900 border-b border-slate-700 text-white flex items-center justify-between shrink-0">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-2xl bg-amber-500/20 border border-amber-500/40 flex items-center justify-center text-amber-400">
              <UserPlus className="w-5 h-5" />
            </div>
            <div>
              <h3 className="text-base font-bold text-white flex items-center gap-2">
                <span>Add New Service Provider</span>
              </h3>
              <p className="text-xs text-slate-300 mt-0.5">
                Register a new verified service provider directly into the platform
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-2 rounded-xl text-slate-400 hover:text-white hover:bg-slate-800 transition-colors cursor-pointer"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Modal Scrollable Form Body */}
        <div className="p-6 overflow-y-auto space-y-6 flex-1 text-slate-800 text-xs">
          
          {errorMsg && (
            <div className="p-3.5 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-xs flex items-center gap-2.5 font-medium animate-in fade-in">
              <AlertCircle className="w-4 h-4 shrink-0 text-rose-600" />
              <span>{errorMsg}</span>
            </div>
          )}

          {successMsg && (
            <div className="p-3.5 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-700 text-xs flex items-center gap-2.5 font-bold animate-in fade-in">
              <CheckCircle2 className="w-4 h-4 shrink-0 text-emerald-600" />
              <span>{successMsg}</span>
            </div>
          )}

          <form id="add-provider-form" onSubmit={handleSubmit} className="space-y-5">
            
            {/* 1. Personal & Contact Information */}
            <div className="space-y-3">
              <div className="flex items-center gap-2 text-slate-900 font-bold text-xs uppercase tracking-wider pb-1 border-b border-slate-100">
                <User className="w-3.5 h-3.5 text-amber-500" />
                <span>1. Personal & Account Details</span>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">
                    Full Name
                  </label>
                  <div className="relative">
                    <User className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                    <input
                      type="text"
                      required
                      value={fullName}
                      onChange={(e) => setFullName(e.target.value)}
                      placeholder="e.g. Sunil Perera"
                      className="w-full pl-9 pr-3 py-2 text-xs bg-slate-50 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-medium text-slate-900"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">
                    Email Address
                  </label>
                  <div className="relative">
                    <Mail className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                    <input
                      type="email"
                      required
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      placeholder="e.g. provider@gmail.com"
                      className="w-full pl-9 pr-3 py-2 text-xs bg-slate-50 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-medium text-slate-900"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">
                    Phone Number
                  </label>
                  <div className="relative">
                    <Phone className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                    <input
                      type="tel"
                      required
                      value={phone}
                      onChange={(e) => setPhone(e.target.value)}
                      placeholder="e.g. 0771234567 or +94771234567"
                      className="w-full pl-9 pr-3 py-2 text-xs bg-slate-50 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-medium text-slate-900"
                    />
                  </div>
                </div>

                <div>
                  <div className="flex items-center justify-between mb-1">
                    <label className="text-xs font-bold text-slate-700">
                      Password
                    </label>
                    <button
                      type="button"
                      onClick={generateStrongPassword}
                      className="text-[11px] font-bold text-amber-600 hover:text-amber-700 flex items-center gap-1 cursor-pointer"
                    >
                      <Sparkles className="w-3 h-3" />
                      <span>Auto Generate</span>
                    </button>
                  </div>
                  <div className="relative">
                    <Lock className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                    <input
                      type={showPassword ? "text" : "password"}
                      required
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      placeholder="Minimum 8 characters (A-Z, a-z, 0-9, @#$)"
                      className="w-full pl-9 pr-9 py-2 text-xs bg-slate-50 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-medium text-slate-900"
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword(!showPassword)}
                      className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 cursor-pointer"
                    >
                      {showPassword ? <EyeOff className="w-3.5 h-3.5" /> : <Eye className="w-3.5 h-3.5" />}
                    </button>
                  </div>

                  {/* Password Strength Live Meter */}
                  {password.length > 0 && (
                    <div className="mt-2 p-2.5 bg-slate-50 border border-slate-200 rounded-xl space-y-1.5 animate-in fade-in duration-200 shadow-xs">
                      <div className="flex items-center justify-between text-[11px]">
                        <span className="text-slate-500 font-bold">Password Strength:</span>
                        <span className={`font-black ${pwdStrength.textColor}`}>
                          {pwdStrength.label}
                        </span>
                      </div>
                      <div className="w-full h-1.5 bg-slate-200 rounded-full overflow-hidden">
                        <div 
                          className={`h-full ${pwdStrength.color} transition-all duration-300 rounded-full`}
                          style={{ width: pwdStrength.barWidth }}
                        />
                      </div>
                      <div className="flex items-center gap-1.5 flex-wrap pt-0.5">
                        <span className={`text-[10px] px-1.5 py-0.5 rounded-md font-bold transition-all ${
                          pwdStrength.hasMinLength ? 'bg-emerald-100 text-emerald-800 border border-emerald-300' : 'bg-slate-200/70 text-slate-500'
                        }`}>
                          {pwdStrength.hasMinLength ? '✓' : '○'} 8+ Chars
                        </span>
                        <span className={`text-[10px] px-1.5 py-0.5 rounded-md font-bold transition-all ${
                          pwdStrength.hasUpper ? 'bg-emerald-100 text-emerald-800 border border-emerald-300' : 'bg-slate-200/70 text-slate-500'
                        }`}>
                          {pwdStrength.hasUpper ? '✓' : '○'} A-Z
                        </span>
                        <span className={`text-[10px] px-1.5 py-0.5 rounded-md font-bold transition-all ${
                          pwdStrength.hasLower ? 'bg-emerald-100 text-emerald-800 border border-emerald-300' : 'bg-slate-200/70 text-slate-500'
                        }`}>
                          {pwdStrength.hasLower ? '✓' : '○'} a-z
                        </span>
                        <span className={`text-[10px] px-1.5 py-0.5 rounded-md font-bold transition-all ${
                          pwdStrength.hasNumber ? 'bg-emerald-100 text-emerald-800 border border-emerald-300' : 'bg-slate-200/70 text-slate-500'
                        }`}>
                          {pwdStrength.hasNumber ? '✓' : '○'} 0-9
                        </span>
                        <span className={`text-[10px] px-1.5 py-0.5 rounded-md font-bold transition-all ${
                          pwdStrength.hasSpecial ? 'bg-emerald-100 text-emerald-800 border border-emerald-300' : 'bg-slate-200/70 text-slate-500'
                        }`}>
                          {pwdStrength.hasSpecial ? '✓' : '○'} @#$%
                        </span>
                      </div>
                    </div>
                  )}
                </div>
              </div>
            </div>

            {/* 2. Professional & Skill Details */}
            <div className="space-y-3 pt-2">
              <div className="flex items-center gap-2 text-slate-900 font-bold text-xs uppercase tracking-wider pb-1 border-b border-slate-100">
                <Wrench className="w-3.5 h-3.5 text-amber-500" />
                <span>2. Service Category & Experience</span>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div className="sm:col-span-2">
                  <label className="block text-xs font-bold text-slate-700 mb-1">
                    Service Category
                  </label>
                  <select
                    value={initialSelectedCategory}
                    onChange={(e) => setCategory(e.target.value)}
                    className="w-full px-3 py-2 text-xs bg-slate-50 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-semibold text-slate-900 cursor-pointer"
                  >
                    {categoryList.map((cat, idx) => (
                      <option key={idx} value={cat.value}>
                        {cat.nameEn} {cat.nameSi ? `(${cat.nameSi})` : ''}
                      </option>
                    ))}
                    <option value="Other">✨ + Other (Add New Custom Category)</option>
                  </select>
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">
                    Experience
                  </label>
                  <div className="relative">
                    <Clock className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                    <select
                      value={experienceYears}
                      onChange={(e) => setExperienceYears(e.target.value)}
                      className="w-full pl-9 pr-3 py-2 text-xs bg-slate-50 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-medium text-slate-900 cursor-pointer"
                    >
                      <option value="1">1 Year</option>
                      <option value="2">2 Years</option>
                      <option value="3">3 Years</option>
                      <option value="5">5+ Years</option>
                      <option value="10">10+ Years</option>
                      <option value="15">15+ Years</option>
                    </select>
                  </div>
                </div>
              </div>

              {/* DYNAMIC OTHER CATEGORY GENERATION BOX */}
              {category === 'Other' && (
                <div className="p-4 rounded-2xl bg-amber-50/70 border-2 border-dashed border-amber-400 space-y-4 animate-in fade-in duration-200">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <Sparkles className="w-4 h-4 text-amber-600 animate-pulse" />
                      <span className="font-extrabold text-xs text-amber-950">
                        Create & Auto-Generate New Service Category
                      </span>
                    </div>
                    <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-amber-200/80 text-amber-900 border border-amber-300">
                      Auto Icon & Multi-Language
                    </span>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="block text-xs font-bold text-slate-700 mb-1">
                        Category English Name
                      </label>
                      <input
                        type="text"
                        required
                        value={customCategoryEn}
                        onChange={(e) => {
                          setCustomCategoryEn(e.target.value);
                          setIsManualIconSelected(false);
                        }}
                        placeholder="e.g. Solar Inverter Repair"
                        className="w-full px-3 py-2 text-xs bg-white rounded-xl border border-slate-300 focus:outline-none focus:border-amber-500 font-semibold text-slate-900 shadow-xs"
                      />
                    </div>

                    <div>
                      <label className="block text-xs font-bold text-slate-700 mb-1">
                        Category Sinhala Name (සිංහල නම)
                      </label>
                      <input
                        type="text"
                        value={customCategorySi}
                        onChange={(e) => {
                          setCustomCategorySi(e.target.value);
                          setIsManualIconSelected(false);
                        }}
                        placeholder="e.g. සූර්ය ඉන්වර්ටර් අලුත්වැඩියාව"
                        className="w-full px-3 py-2 text-xs bg-white rounded-xl border border-slate-300 focus:outline-none focus:border-amber-500 font-semibold text-slate-900 shadow-xs"
                      />
                    </div>
                  </div>

                  {/* Auto-Generated Icon Preview & Selector */}
                  <div className="p-3 bg-white rounded-xl border border-amber-200 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 shadow-xs">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-xl bg-amber-500 text-slate-950 flex items-center justify-center shadow-sm shrink-0">
                        <SelectedIconComponent className="w-5 h-5" />
                      </div>
                      <div>
                        <div className="flex items-center gap-1.5">
                          <span className="text-xs font-black text-slate-900">
                            {customCategoryEn.trim() || 'New Category Name'}
                          </span>
                          {customCategorySi.trim() && (
                            <span className="text-xs text-slate-500 font-medium">
                              ({customCategorySi.trim()})
                            </span>
                          )}
                        </div>
                        <p className="text-[11px] text-amber-700 font-bold flex items-center gap-1 mt-0.5">
                          <Sparkles className="w-3 h-3 text-amber-600" />
                          <span>Auto-detected Icon: <strong>{customCategoryIcon}</strong></span>
                        </p>
                      </div>
                    </div>

                    {/* Quick Icon Override Picker */}
                    <div className="flex items-center gap-1 flex-wrap">
                      <span className="text-[10px] text-slate-400 font-medium mr-1">Choose Icon:</span>
                      {AVAILABLE_ICONS.slice(0, 7).map((iconKey) => {
                        const IconComp = ICON_MAP[iconKey] || Wrench;
                        const isSelected = customCategoryIcon === iconKey;
                        return (
                          <button
                            key={iconKey}
                            type="button"
                            onClick={() => {
                              setCustomCategoryIcon(iconKey);
                              setIsManualIconSelected(true);
                            }}
                            title={iconKey}
                            className={`p-1.5 rounded-lg border transition-all cursor-pointer ${
                              isSelected 
                                ? 'bg-amber-500 text-slate-950 border-amber-600 scale-110 shadow-xs font-bold' 
                                : 'bg-slate-50 text-slate-600 border-slate-200 hover:bg-amber-100 hover:border-amber-300'
                            }`}
                          >
                            <IconComp className="w-3.5 h-3.5" />
                          </button>
                        );
                      })}
                    </div>
                  </div>
                </div>
              )}

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">
                    NIC Number (National Identity Card)
                  </label>
                  <div className="relative">
                    <CreditCard className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                    <input
                      type="text"
                      value={nicNumber}
                      onChange={(e) => setNicNumber(e.target.value)}
                      placeholder="e.g. 199512345678 or 951234567V"
                      className="w-full pl-9 pr-3 py-2 text-xs bg-slate-50 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-medium text-slate-900"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">
                    Working Radius
                  </label>
                  <div className="relative">
                    <Compass className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                    <select
                      value={workingRadius}
                      onChange={(e) => setWorkingRadius(e.target.value)}
                      className="w-full pl-9 pr-3 py-2 text-xs bg-slate-50 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-medium text-slate-900 cursor-pointer"
                    >
                      <option value="10">10 KM</option>
                      <option value="20">20 KM</option>
                      <option value="25">25 KM (Standard)</option>
                      <option value="35">35 KM</option>
                      <option value="50">50 KM (Wide Area)</option>
                      <option value="100">100 KM (Islandwide)</option>
                    </select>
                  </div>
                </div>
              </div>
            </div>

            {/* 3. Location & Coverage with Bilingual District & Cities */}
            <div className="space-y-3 pt-2">
              <div className="flex items-center gap-2 text-slate-900 font-bold text-xs uppercase tracking-wider pb-1 border-b border-slate-100">
                <MapPin className="w-3.5 h-3.5 text-amber-500" />
                <span>3. Location & Coverage Area</span>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">
                    District (දිස්ත්‍රික්කය)
                  </label>
                  <select
                    value={district}
                    onChange={(e) => handleDistrictChange(e.target.value)}
                    className="w-full px-3 py-2 text-xs bg-slate-50 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-semibold text-slate-900 cursor-pointer"
                  >
                    {SRI_LANKA_DISTRICTS_BILINGUAL.map((dist) => (
                      <option key={dist.id} value={dist.id}>
                        {dist.en} ({dist.si})
                      </option>
                    ))}
                  </select>
                </div>

                <div>
                  <div className="flex items-center justify-between mb-1">
                    <label className="block text-xs font-bold text-slate-700">
                      City / Town ({selectedDistrictObj?.en} - {selectedDistrictObj?.si})
                    </label>
                    <span className="text-[10px] text-slate-400 font-medium">
                      {currentDistrictCities.length} Cities
                    </span>
                  </div>
                  <div className="relative">
                    <Building className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                    <select
                      value={city}
                      onChange={(e) => setCity(e.target.value)}
                      className="w-full pl-9 pr-3 py-2 text-xs bg-slate-50 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-semibold text-slate-900 cursor-pointer"
                    >
                      {currentDistrictCities.map((cityName, idx) => (
                        <option key={idx} value={cityName.en}>
                          {cityName.en} ({cityName.si})
                        </option>
                      ))}
                      <option value="Other">+ Other / Custom Town (වෙනත් නගරයක්)...</option>
                    </select>
                  </div>

                  {city === 'Other' && (
                    <div className="mt-2 animate-in fade-in">
                      <input
                        type="text"
                        required
                        value={customCity}
                        onChange={(e) => setCustomCity(e.target.value)}
                        placeholder="Enter specific village or town name (නගරයේ නම)..."
                        className="w-full px-3 py-2 text-xs bg-white rounded-xl border border-amber-400 focus:outline-none focus:border-amber-500 font-medium text-slate-900 shadow-xs"
                      />
                    </div>
                  )}
                </div>

                <div className="sm:col-span-2">
                  <label className="block text-xs font-bold text-slate-700 mb-1">
                    Street Address (ලිපිනය)
                  </label>
                  <input
                    type="text"
                    value={address}
                    onChange={(e) => setAddress(e.target.value)}
                    placeholder="e.g. No. 45/2, Temple Road, Maharagama"
                    className="w-full px-3 py-2 text-xs bg-slate-50 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-medium text-slate-900"
                  />
                </div>
              </div>
            </div>

            {/* 4. Verification & Status Toggle */}
            <div className="p-4 rounded-2xl bg-amber-500/10 border border-amber-500/30 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-xl bg-amber-500 text-slate-950 flex items-center justify-center font-bold">
                  <ShieldCheck className="w-4 h-4" />
                </div>
                <div>
                  <p className="text-xs font-bold text-slate-900">
                    Auto-Approve & Activate Profile
                  </p>
                  <p className="text-[11px] text-slate-600">
                    When enabled, the provider will be instantly activated and verified on the mobile app.
                  </p>
                </div>
              </div>

              <input
                type="checkbox"
                checked={isAutoApprove}
                onChange={(e) => setIsAutoApprove(e.target.checked)}
                className="w-5 h-5 accent-amber-500 rounded cursor-pointer"
              />
            </div>

          </form>
        </div>

        {/* Modal Footer Actions */}
        <div className="px-6 py-4 bg-slate-50 border-t border-slate-200 flex items-center justify-end gap-3 shrink-0">
          <button
            type="button"
            onClick={onClose}
            disabled={loading}
            className="px-5 py-2.5 rounded-xl border border-slate-300 text-slate-700 hover:bg-slate-100 font-bold text-xs transition-colors cursor-pointer"
          >
            Cancel
          </button>
          
          <button
            type="submit"
            form="add-provider-form"
            disabled={loading}
            className="px-6 py-2.5 rounded-xl bg-amber-500 hover:bg-amber-600 text-slate-950 font-extrabold text-xs shadow-md flex items-center gap-2 transition-all cursor-pointer disabled:opacity-50"
          >
            {loading ? (
              <>
                <RefreshCw className="w-4 h-4 animate-spin" />
                <span>Creating Provider...</span>
              </>
            ) : (
              <>
                <UserPlus className="w-4 h-4" />
                <span>Create Provider</span>
              </>
            )}
          </button>
        </div>

      </div>
    </div>,
    document.body
  );
}
