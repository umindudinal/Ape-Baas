import React, { useState } from 'react';
import { 
  Bell, 
  Send, 
  Clock, 
  CheckCircle2, 
  Megaphone
} from 'lucide-react';

const NotificationsPage = ({ notifications, onSendNotification }) => {
  const [title, setTitle] = useState('');
  const [message, setMessage] = useState('');
  const [targetAudience, setTargetAudience] = useState('All Customers');

  const handleSend = (e) => {
    e.preventDefault();
    if (!title || !message) return;

    onSendNotification({
      id: `NTF-${Date.now()}`,
      title,
      message,
      target: targetAudience,
      sentAt: new Date().toLocaleString(),
      status: 'Delivered'
    });

    setTitle('');
    setMessage('');
  };

  const applyTemplate = (tmpl) => {
    if (tmpl === 'offer') {
      setTitle('New Year Special Discount Offer! 🎉');
      setMessage('Enjoy 20% flat discount on all home maintenance services this week.');
      setTargetAudience('All Customers');
    } else if (tmpl === 'update') {
      setTitle('Ape Baas Mobile App Version 2.4 Update 🚀');
      setMessage('Please update your mobile app to version 2.4 for enhanced performance and security.');
      setTargetAudience('All Users');
    } else if (tmpl === 'provider') {
      setTitle('Important Notice to All Service Providers 🛠️');
      setMessage('Please submit your National Identity Card (NIC) documents to keep your provider account verified.');
      setTargetAudience('All Providers');
    }
  };

  return (
    <div className="space-y-6 animate-in fade-in duration-300">
      {/* Header Banner */}
      <div className="p-6 rounded-2xl bg-white border border-slate-200 shadow-xs">
        <h3 className="text-xl font-bold text-slate-900 flex items-center gap-2">
          <Bell className="w-6 h-6 text-amber-600" />
          Push Notifications & Announcements
        </h3>
        <p className="text-xs text-slate-500 mt-1">
          Broadcast mobile push notifications and operational updates to customers or service providers.
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Create Broadcast Notification Form */}
        <div className="lg:col-span-2 p-6 rounded-2xl bg-white border border-slate-200 shadow-xs space-y-4">
          <div className="flex items-center justify-between border-b border-slate-100 pb-3">
            <h4 className="font-bold text-slate-900 text-base flex items-center gap-2">
              <Megaphone className="w-5 h-5 text-amber-600" />
              Compose New Push Broadcast
            </h4>
          </div>

          {/* Quick Templates */}
          <div>
            <label className="text-xs font-semibold text-slate-600 block mb-2">Quick Templates:</label>
            <div className="flex flex-wrap gap-2">
              <button
                type="button"
                onClick={() => applyTemplate('offer')}
                className="px-3 py-1.5 rounded-lg bg-amber-50 hover:bg-amber-100 text-amber-800 border border-amber-200 text-xs font-medium transition-colors"
              >
                🎉 New Year Offer
              </button>
              <button
                type="button"
                onClick={() => applyTemplate('update')}
                className="px-3 py-1.5 rounded-lg bg-emerald-50 hover:bg-emerald-100 text-emerald-800 border border-emerald-200 text-xs font-medium transition-colors"
              >
                🚀 App Update Notice
              </button>
              <button
                type="button"
                onClick={() => applyTemplate('provider')}
                className="px-3 py-1.5 rounded-lg bg-blue-50 hover:bg-blue-100 text-blue-800 border border-blue-200 text-xs font-medium transition-colors"
              >
                🛠️ Provider Verification Alert
              </button>
            </div>
          </div>

          <form onSubmit={handleSend} className="space-y-4 text-xs pt-2">
            <div>
              <label className="text-slate-700 font-semibold block mb-1">
                Target Audience:
              </label>
              <select
                value={targetAudience}
                onChange={(e) => setTargetAudience(e.target.value)}
                className="w-full p-3 bg-slate-50 text-slate-900 border border-slate-300 rounded-xl font-semibold focus:bg-white focus:border-amber-500 focus:outline-hidden"
              >
                <option value="All Customers">👥 All Customers Only</option>
                <option value="All Providers">🛠️ All Providers Only</option>
                <option value="All Users">🌐 All Users (Everyone)</option>
              </select>
            </div>

            <div>
              <label className="text-slate-700 font-semibold block mb-1">
                Notification Title:
              </label>
              <input
                type="text"
                required
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                placeholder="e.g. 20% Special Discount Today!"
                className="w-full p-3 bg-slate-50 text-slate-900 rounded-xl border border-slate-300 focus:bg-white focus:border-amber-500 focus:outline-hidden"
              />
            </div>

            <div>
              <label className="text-slate-700 font-semibold block mb-1">
                Body Content:
              </label>
              <textarea
                required
                rows={4}
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                placeholder="Type push notification content here..."
                className="w-full p-3 bg-slate-50 text-slate-900 rounded-xl border border-slate-300 focus:bg-white focus:border-amber-500 focus:outline-hidden"
              />
            </div>

            <button
              type="submit"
              className="w-full py-3.5 rounded-xl bg-amber-500 hover:bg-amber-600 text-slate-950 font-extrabold text-sm flex items-center justify-center gap-2 shadow-xs transition-all active:scale-[0.99] cursor-pointer"
            >
              <Send className="w-4 h-4" />
              <span>Send Push Notification Now</span>
            </button>
          </form>
        </div>

        {/* Sent Notification History */}
        <div className="p-6 rounded-2xl bg-white border border-slate-200 shadow-xs space-y-4">
          <h4 className="font-bold text-slate-900 text-base border-b border-slate-100 pb-3 flex items-center gap-2">
            <Clock className="w-4 h-4 text-emerald-600" />
            Broadcast History
          </h4>

          <div className="space-y-3 max-h-[500px] overflow-y-auto pr-1">
            {notifications.map((ntf) => (
              <div key={ntf.id} className="p-4 rounded-xl bg-slate-50 border border-slate-200 space-y-2">
                <div className="flex items-center justify-between text-[11px]">
                  <span className="font-bold text-amber-800 px-2 py-0.5 rounded-md bg-amber-100 border border-amber-200">
                    {ntf.target}
                  </span>
                  <span className="text-slate-400">{ntf.sentAt}</span>
                </div>
                <h5 className="font-bold text-slate-900 text-xs">{ntf.title}</h5>
                <p className="text-[11px] text-slate-600 leading-relaxed">{ntf.message}</p>
                <div className="flex items-center justify-end text-[10px] text-emerald-700 font-bold gap-1 pt-1">
                  <CheckCircle2 className="w-3 h-3" /> Delivered
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

export default NotificationsPage;
