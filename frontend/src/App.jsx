import { useState, useRef, useEffect } from 'react';
import ReactMarkdown from 'react-markdown';
import { 
  LayoutDashboard, 
  FileText, 
  Plus, 
  ArrowRight, 
  Clock, 
  Search, 
  ChevronRight, 
  BarChart3, 
  TrendingUp, 
  AlertCircle,
  CheckCircle2,
  Loader2
} from 'lucide-react';

// --- Mock Data & Types ---
const INITIAL_HISTORY = [
  { 
    id: '1', 
    query: "Why did revenue drop in EMEA?", 
    timestamp: "2023-10-24T10:30:00",
    summary: "Revenue drop attributed to new compliance regulations affecting enterprise sales cycle."
  },
  { 
    id: '2', 
    query: "Q3 Marketing ROI Analysis", 
    timestamp: "2023-10-23T14:15:00",
    summary: "Q3 ROI up by 12% driven by organic search improvements."
  }
];

const SUGGESTED_ACTIONS = [
  { title: "Analyze Monthly Revenue", icon: BarChart3, color: "text-blue-600", bg: "bg-blue-50" },
  { title: "Explain Churn Spike", icon: TrendingUp, color: "text-red-600", bg: "bg-red-50" },
  { title: "Identify Key Risks", icon: AlertCircle, color: "text-amber-600", bg: "bg-amber-50" },
];

function App() {
  const [history, setHistory] = useState(INITIAL_HISTORY);
  const [currentReportId, setCurrentReportId] = useState(null);
  const [prompt, setPrompt] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const textareaRef = useRef(null);

  const currentReport = history.find(h => h.id === currentReportId);

  // Auto-resize textarea
  useEffect(() => {
    if (textareaRef.current) {
      textareaRef.current.style.height = 'auto';
      textareaRef.current.style.height = textareaRef.current.scrollHeight + 'px';
    }
  }, [prompt]);

  const handleGenerate = async () => {
    if (!prompt.trim()) return;

    setLoading(true);
    setError("");
    
    // Optimistic update for UI feel (optional, but good for "Thinking")
    // In a real app, we might create a placeholder ID
    
    try {
      const res = await fetch("http://localhost:3000/reports", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ prompt })
      });

      const data = await res.json();

      if (!res.ok) {
        throw new Error(data.error || "Failed to generate report.");
      }

      // Create new report object
      const newReport = {
        id: Date.now().toString(),
        query: prompt,
        timestamp: new Date().toISOString(),
        summary: data.analysis ? data.analysis.slice(0, 100) + "..." : "No summary available",
        fullAnalysis: data.analysis
      };

      setHistory([newReport, ...history]);
      setCurrentReportId(newReport.id);
      setPrompt(""); // Clear input on success
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const startNewAnalysis = () => {
    setCurrentReportId(null);
    setPrompt("");
    setError("");
    // Focus input?
  };

  return (
    <div className="flex h-screen bg-slate-50 font-sans text-slate-900">
      {/* --- Sidebar --- */}
      <aside className="w-72 bg-slate-900 text-slate-300 flex flex-col border-r border-slate-800 flex-shrink-0">
        <div className="p-4 border-b border-slate-800 flex items-center gap-3">
          <div className="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center text-white">
            <BarChart3 size={18} />
          </div>
          <span className="font-semibold text-white tracking-tight">SmartAnalyst</span>
        </div>

        <div className="p-4">
          <button 
            onClick={startNewAnalysis}
            className="w-full bg-blue-600 hover:bg-blue-500 text-white px-4 py-2.5 rounded-lg flex items-center justify-center gap-2 font-medium transition-colors shadow-sm"
          >
            <Plus size={18} />
            New Analysis
          </button>
        </div>

        <div className="flex-1 overflow-y-auto px-2">
          <div className="px-2 pb-2 text-xs font-semibold text-slate-500 uppercase tracking-wider">History</div>
          <div className="space-y-1">
            {history.map((item) => (
              <button
                key={item.id}
                onClick={() => setCurrentReportId(item.id)}
                className={`w-full text-left px-3 py-3 rounded-lg flex items-start gap-3 transition-colors ${currentReportId === item.id 
                  ? "bg-slate-800 text-white" 
                  : "hover:bg-slate-800/50 text-slate-400 hover:text-slate-200"}
                }`}
              >
                <FileText size={16} className="mt-0.5 flex-shrink-0" />
                <div className="truncate text-sm font-medium leading-snug">
                  {item.query}
                </div>
              </button>
            ))}
          </div>
        </div>

        <div className="p-4 border-t border-slate-800 text-xs text-slate-500">
          v1.0.2 • Connected to Live DB
        </div>
      </aside>

      {/* --- Main Workspace --- */}
      <main className="flex-1 flex flex-col relative min-w-0">
        
        {/* Header (Context) */}
        <header className="h-16 border-b border-slate-200 bg-white flex items-center px-6 justify-between flex-shrink-0">
            <div className="flex items-center gap-2 text-sm text-slate-500">
              <LayoutDashboard size={16} />
              <ChevronRight size={14} />
              <span className="font-medium text-slate-900">
                {currentReport ? "Report View" : "Dashboard"}
              </span>
            </div>
            <div className="flex items-center gap-2">
               <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-green-50 text-green-700 border border-green-200">
                 <div className="w-1.5 h-1.5 rounded-full bg-green-500 animate-pulse"></div>
                 System Online
               </span>
            </div>
        </header>

        {/* Scrollable Content */}
        <div className="flex-1 overflow-y-auto p-6 md:p-12 scroll-smooth">
          <div className="max-w-4xl mx-auto w-full">
            
            {/* ERROR STATE */}
            {error && (
              <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg text-red-700 flex items-start gap-3">
                <AlertCircle size={20} className="mt-0.5 flex-shrink-0" />
                <div>
                  <h4 className="font-medium">Analysis Failed</h4>
                  <p className="text-sm mt-1 opacity-90">{error}</p>
                </div>
              </div>
            )}

            {/* EMPTY STATE */}
            {!currentReport && !loading && (
              <div className="mt-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
                <h1 className="text-3xl font-bold text-slate-900 mb-2">Welcome back, Analyst.</h1>
                <p className="text-slate-500 text-lg mb-8">What would you like to investigate today?</p>
                
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-12">
                  {SUGGESTED_ACTIONS.map((action, i) => (
                    <button 
                      key={i}
                      onClick={() => setPrompt(action.title)}
                      className="p-4 rounded-xl border border-slate-200 bg-white hover:border-blue-300 hover:shadow-md transition-all text-left group"
                    >
                      <div className={`w-10 h-10 rounded-lg ${action.bg} ${action.color} flex items-center justify-center mb-3 group-hover:scale-110 transition-transform`}>
                        <action.icon size={20} />
                      </div>
                      <h3 className="font-semibold text-slate-900">{action.title}</h3>
                      <p className="text-sm text-slate-500 mt-1">Generate deep dive analysis.</p>
                    </button>
                  ))}
                </div>
              </div>
            )}

            {/* REPORT VIEW */}
            {currentReport && !loading && (
              <div className="animate-in fade-in zoom-in-95 duration-300">
                <div className="mb-6">
                  <h1 className="text-2xl font-bold text-slate-900 leading-tight">
                    Analysis: {currentReport.query}
                  </h1>
                  <div className="flex items-center gap-4 mt-3 text-sm text-slate-500">
                    <span className="flex items-center gap-1.5">
                      <Clock size={14} />
                      {new Date(currentReport.timestamp).toLocaleString()}
                    </span>
                    <span className="flex items-center gap-1.5 text-blue-600 font-medium bg-blue-50 px-2 py-0.5 rounded-full">
                      <CheckCircle2 size={14} />
                      Verified by Live Data
                    </span>
                  </div>
                </div>

                <div className="prose prose-slate max-w-none prose-headings:font-semibold prose-h2:text-slate-800 prose-h2:mt-8 prose-h2:mb-4 prose-p:text-slate-600 prose-strong:text-slate-900 prose-li:text-slate-600">
                  {/* If we had a full markdown string from backend, we'd use it here. 
                      Since we constructed it manually in handleGenerate, we use fullAnalysis. 
                      For history items 1 & 2 (mocks), we only have summary. Handle gracefully. */}
                  <ReactMarkdown>
                    {currentReport.fullAnalysis || `### Executive Summary\n\n${currentReport.summary}\n\n*(Full historical data not available in this demo view)*`}
                  </ReactMarkdown>
                </div>
                
                <div className="mt-12 pt-8 border-t border-slate-200 text-center">
                  <p className="text-sm text-slate-400">
                    Confidential Report • Generated by AI Agent
                  </p>
                </div>
              </div>
            )}

            {/* LOADING STATE */}
            {loading && (
               <div className="flex flex-col items-center justify-center py-20 animate-in fade-in duration-500">
                 <div className="relative">
                   <div className="w-16 h-16 border-4 border-slate-100 border-t-blue-600 rounded-full animate-spin"></div>
                   <div className="absolute inset-0 flex items-center justify-center">
                     <BarChart3 size={24} className="text-blue-600 opacity-50" />
                   </div>
                 </div>
                 <h3 className="mt-6 text-xl font-semibold text-slate-900">Analyzing Market Data...</h3>
                 <p className="text-slate-500 mt-2">Cross-referencing SQL database with latest metrics.</p>
               </div>
            )}

          </div>
        </div>

        {/* Input Area (Sticky Bottom) */}
        {!currentReport && !loading && (
          <div className="p-6 bg-white border-t border-slate-200 sticky bottom-0 z-10">
            <div className="max-w-4xl mx-auto relative">
              <textarea
                ref={textareaRef}
                value={prompt}
                onChange={(e) => setPrompt(e.target.value)}
                placeholder="Ask a question about your business performance..."
                className="w-full bg-slate-50 border border-slate-200 rounded-xl p-4 pr-32 focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all resize-none shadow-sm text-slate-900 placeholder:text-slate-400 min-h-[60px] max-h-[200px]"
                rows={1}
                onKeyDown={(e) => {
                  if (e.key === 'Enter' && !e.shiftKey) {
                    e.preventDefault();
                    handleGenerate();
                  }
                }}
              />
              <div className="absolute right-3 bottom-3">
                <button
                  onClick={handleGenerate}
                  disabled={!prompt.trim() || loading}
                  className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
                >
                  {loading ? <Loader2 size={16} className="animate-spin" /> : "Generate"}
                </button>
              </div>
            </div>
            <div className="text-center mt-3 text-xs text-slate-400">
              AI can make mistakes. Please verify critical financial data.
            </div>
          </div>
        )}
      </main>
    </div>
  );
}

export default App;