// import React, { useState, useEffect, useRef } from "react";
// import { useNavigate } from "react-router-dom";
// import axios from "axios";
// import { gsap } from "gsap";
// import { useAuth } from "../context/AuthContext";

// const MODELS = ["llama2", "mistral", "gemma", "phi", "codellama", "llama3"];

// // 📄 Read file contents as text
// const readFileAsText = (file) => {
//   return new Promise((resolve, reject) => {
//     const reader = new FileReader();

//     if (file.type === "application/pdf") {
//       // For PDF: read as ArrayBuffer, extract raw text
//       reader.onload = async (e) => {
//         try {
//           // Use basic PDF text extraction (no external lib needed)
//           const buffer = e.target.result;
//           const bytes = new Uint8Array(buffer);
//           let text = "";
//           // Extract readable ASCII text from PDF bytes
//           for (let i = 0; i < bytes.length; i++) {
//             const b = bytes[i];
//             if (b >= 32 && b < 127) {
//               text += String.fromCharCode(b);
//             } else if (b === 10 || b === 13) {
//               text += " ";
//             }
//           }
//           // Clean up PDF junk, keep meaningful words (3+ chars)
//           const words = text.split(/\s+/).filter(w => w.length > 2 && /[a-zA-Z]/.test(w));
//           const cleaned = words.join(" ").substring(0, 8000);
//           resolve(cleaned || "Could not extract text from PDF.");
//         } catch (err) {
//           reject(err);
//         }
//       };
//       reader.onerror = reject;
//       reader.readAsArrayBuffer(file);
//     } else {
//       // Plain text, markdown, csv, json, code files
//       reader.onload = (e) => resolve(e.target.result.substring(0, 8000));
//       reader.onerror = reject;
//       reader.readAsText(file);
//     }
//   });
// };

// const ACCEPTED_TYPES = ".txt,.md,.csv,.json,.js,.py,.html,.css,.ts,.pdf,.xml,.yaml,.yml,.log";

// export default function Chat() {
//   const { user, logout } = useAuth();
//   const navigate = useNavigate();
//   const [messages, setMessages] = useState([]);
//   const [input, setInput] = useState("");
//   const [isTyping, setIsTyping] = useState(false);
//   const [chatHistory, setChatHistory] = useState([]);
//   const [currentChatId, setCurrentChatId] = useState(null);
//   const [model, setModel] = useState("llama2:latest");
//   const [sidebarOpen, setSidebarOpen] = useState(true);
//   const [availableModels, setAvailableModels] = useState(MODELS);

//   // 🎤 Voice states
//   const [isListening, setIsListening] = useState(false);
//   const [isSpeaking, setIsSpeaking] = useState(false);
//   const [voiceEnabled, setVoiceEnabled] = useState(false);
//   const [transcript, setTranscript] = useState("");
//   const [voiceSupported, setVoiceSupported] = useState(false);

//   // 📎 Attachment states
//   const [attachedFile, setAttachedFile] = useState(null); // { name, content, type, size }
//   const [isReadingFile, setIsReadingFile] = useState(false);

//   const messagesEndRef = useRef(null);
//   const inputRef = useRef(null);
//   const sidebarRef = useRef(null);
//   const headerRef = useRef(null);
//   const recognitionRef = useRef(null);
//   const synthRef = useRef(window.speechSynthesis);
//   const fileInputRef = useRef(null);

//   useEffect(() => {
//     const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
//     if (SpeechRecognition) {
//       setVoiceSupported(true);
//       const recognition = new SpeechRecognition();
//       recognition.continuous = false;
//       recognition.interimResults = true;
//       recognition.lang = "en-US";
//       recognition.onstart = () => { setIsListening(true); setTranscript(""); };
//       recognition.onresult = (event) => {
//         let interim = "", final = "";
//         for (let i = event.resultIndex; i < event.results.length; i++) {
//           const t = event.results[i][0].transcript;
//           event.results[i].isFinal ? (final += t) : (interim += t);
//         }
//         setInput(final || interim);
//         setTranscript(final || interim);
//       };
//       recognition.onend = () => {
//         setIsListening(false);
//         if (recognitionRef.current._shouldSend) {
//           recognitionRef.current._shouldSend = false;
//           setTimeout(() => { document.getElementById("send-btn")?.click(); }, 300);
//         }
//       };
//       recognition.onerror = (e) => {
//         setIsListening(false);
//         if (e.error === "not-allowed") alert("Microphone access denied. Please allow microphone in browser settings.");
//       };
//       recognitionRef.current = recognition;
//     }

//     const tl = gsap.timeline();
//     tl.fromTo(headerRef.current, { opacity: 0, y: -20 }, { opacity: 1, y: 0, duration: 0.5, ease: "power2.out" });
//     if (sidebarRef.current) tl.fromTo(sidebarRef.current, { opacity: 0, x: -30 }, { opacity: 1, x: 0, duration: 0.5, ease: "power2.out" }, "-=0.3");

//     fetchHistory();
//     fetchModels();
//     setMessages([{
//       role: "assistant",
//       content: `Hello **${user?.username}**! 👋 I'm your offline AI assistant powered by **Ollama**. You can type, speak 🎤, or attach a document 📎 and ask questions about it!`,
//       id: Date.now(),
//     }]);

//     return () => {
//       recognitionRef.current?.abort();
//       synthRef.current?.cancel();
//     };
//   }, []);

//   useEffect(() => { scrollToBottom(); }, [messages, isTyping]);

//   const scrollToBottom = () => messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });

//   // 📎 Handle file attachment
//   const handleFileAttach = async (e) => {
//     const file = e.target.files[0];
//     if (!file) return;
//     e.target.value = ""; // reset input

//     const maxSize = 5 * 1024 * 1024; // 5MB
//     if (file.size > maxSize) {
//       alert("File too large. Please attach files under 5MB.");
//       return;
//     }

//     setIsReadingFile(true);
//     gsap.fromTo("#attach-preview", { opacity: 0, y: 10 }, { opacity: 1, y: 0, duration: 0.3 });

//     try {
//       const content = await readFileAsText(file);
//       setAttachedFile({
//         name: file.name,
//         type: file.type || "text/plain",
//         size: (file.size / 1024).toFixed(1) + " KB",
//         content,
//       });
//     } catch (err) {
//       console.error("File read error:", err);
//       alert("Could not read this file. Please try a different format.");
//     } finally {
//       setIsReadingFile(false);
//     }
//   };

//   const removeAttachment = () => {
//     setAttachedFile(null);
//     gsap.to("#attach-preview", { opacity: 0, y: 10, duration: 0.2 });
//   };

//   // 🎤 Voice
//   const startListening = () => {
//     if (!recognitionRef.current || isListening) return;
//     synthRef.current?.cancel();
//     setIsSpeaking(false);
//     recognitionRef.current._shouldSend = true;
//     recognitionRef.current.start();
//     gsap.to("#mic-btn", { scale: 1.15, duration: 0.2, yoyo: true, repeat: -1, ease: "power1.inOut" });
//   };

//   const stopListening = () => {
//     if (recognitionRef.current && isListening) {
//       recognitionRef.current._shouldSend = false;
//       recognitionRef.current.stop();
//       gsap.killTweensOf("#mic-btn");
//       gsap.to("#mic-btn", { scale: 1, duration: 0.2 });
//     }
//   };

//   const speakText = (text) => {
//     if (!voiceEnabled || !synthRef.current) return;
//     const clean = text.replace(/\*\*(.*?)\*\*/g, "$1").replace(/`(.*?)`/g, "$1").replace(/<[^>]*>/g, "").replace(/[🎤🔊🤖👋❌📎]/g, "");
//     synthRef.current.cancel();
//     const utterance = new SpeechSynthesisUtterance(clean);
//     utterance.rate = 1.0; utterance.pitch = 1.0; utterance.volume = 1.0;
//     const voices = synthRef.current.getVoices();
//     const preferred = voices.find(v => v.name.includes("Google") || v.lang === "en-US");
//     if (preferred) utterance.voice = preferred;
//     utterance.onstart = () => setIsSpeaking(true);
//     utterance.onend = () => setIsSpeaking(false);
//     utterance.onerror = () => setIsSpeaking(false);
//     synthRef.current.speak(utterance);
//   };

//   const stopSpeaking = () => { synthRef.current?.cancel(); setIsSpeaking(false); };

//   const fetchHistory = async () => {
//     try {
//       const res = await axios.get("http://localhost:5005/api/chat/history");
//       setChatHistory(res.data.chats || []);
//     } catch (e) { console.error(e); }
//   };

//   const fetchModels = async () => {
//     try {
//       const res = await axios.get("http://localhost:5005/api/chat/models/list");
//       if (res.data.models?.length > 0) {
//         setAvailableModels(res.data.models.map(m => m.name));
//         setModel(res.data.models[0].name);
//       }
//     } catch (e) { }
//   };

//   const sendMessage = async () => {
//     if (!input.trim() || isTyping) return;

//     // Build prompt — inject file content if attached
//     let promptMessage = input.trim();
//     let displayMessage = input.trim();

//     if (attachedFile) {
//       promptMessage = `I have attached a file named "${attachedFile.name}". Here is its content:\n\n---\n${attachedFile.content}\n---\n\nBased on this document, please answer: ${input.trim()}`;
//       displayMessage = `📎 **${attachedFile.name}**\n${input.trim()}`;
//     }

//     const userMsg = { role: "user", content: displayMessage, id: Date.now() };
//     setMessages(prev => [...prev, userMsg]);
//     setInput("");
//     setTranscript("");
//     setAttachedFile(null); // clear attachment after send
//     setIsTyping(true);

//     gsap.killTweensOf("#mic-btn");
//     gsap.to("#mic-btn", { scale: 1, duration: 0.1 });
//     gsap.to("#send-btn", { scale: 0.85, duration: 0.1, yoyo: true, repeat: 1 });

//     try {
//       const token = localStorage.getItem("token");
//       const response = await fetch("http://localhost:5005/api/chat/message", {
//         method: "POST",
//         headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
//         body: JSON.stringify({ message: promptMessage, chatId: currentChatId, model }),
//       });

//       if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);

//       const aiMsgId = Date.now() + 1;
//       setMessages(prev => [...prev, { role: "assistant", content: "", id: aiMsgId }]);
//       setIsTyping(false);

//       const reader = response.body.getReader();
//       const decoder = new TextDecoder();
//       let fullAiResponse = "";

//       while (true) {
//         const { done, value } = await reader.read();
//         if (done) break;
//         const text = decoder.decode(value);
//         const lines = text.split("\n").filter(l => l.startsWith("data: "));
//         for (const line of lines) {
//           try {
//             const data = JSON.parse(line.slice(6));
//             if (data.token) {
//               fullAiResponse += data.token;
//               setMessages(prev => prev.map(m => m.id === aiMsgId ? { ...m, content: m.content + data.token } : m));
//             }
//             if (data.done) { fetchHistory(); if (voiceEnabled && fullAiResponse) speakText(fullAiResponse); }
//             if (data.error) setMessages(prev => prev.map(m => m.id === aiMsgId ? { ...m, content: "❌ " + data.error } : m));
//           } catch { }
//         }
//       }
//     } catch (err) {
//       setIsTyping(false);
//       setMessages(prev => [...prev, { role: "assistant", content: "❌ Error connecting to Ollama. Make sure Ollama is running on `http://localhost:11434`", id: Date.now() }]);
//     }
//   };

//   const loadChat = async (chatId) => {
//     try {
//       const res = await axios.get(`http://localhost:5005/api/chat/${chatId}`);
//       setMessages(res.data.chat.messages.map((m, i) => ({ ...m, id: i })));
//       setCurrentChatId(chatId);
//     } catch (e) { console.error(e); }
//   };

//   const newChat = () => {
//     synthRef.current?.cancel();
//     setAttachedFile(null);
//     setMessages([{ role: "assistant", content: `Hello **${user?.username}**! 👋 Starting a new conversation. What's on your mind?`, id: Date.now() }]);
//     setCurrentChatId(null);
//     gsap.fromTo("#chat-area", { opacity: 0 }, { opacity: 1, duration: 0.4 });
//   };

//   const deleteChat = async (e, chatId) => {
//     e.stopPropagation();
//     try {
//       await axios.delete(`http://localhost:5005/api/chat/${chatId}`);
//       setChatHistory(prev => prev.filter(c => c._id !== chatId));
//       if (currentChatId === chatId) newChat();
//     } catch (e) { console.error(e); }
//   };

//   const handleLogout = () => {
//     synthRef.current?.cancel();
//     gsap.to("body", { opacity: 0, duration: 0.3, onComplete: () => { logout(); navigate("/login"); } });
//   };

//   const handleKey = (e) => {
//     if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); sendMessage(); }
//   };

//   const getFileIcon = (name) => {
//     const ext = name.split(".").pop().toLowerCase();
//     const icons = { pdf: "📄", js: "📜", py: "🐍", html: "🌐", css: "🎨", json: "📋", csv: "📊", md: "📝", txt: "📃", ts: "📘" };
//     return icons[ext] || "📎";
//   };

//   const renderMarkdown = (text) => {
//     return text
//       .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
//       .replace(/`(.*?)`/g, '<code style="background:rgba(0,212,255,0.1);padding:2px 6px;border-radius:4px;font-family:monospace;font-size:13px;color:var(--accent)">$1</code>')
//       .replace(/\n/g, '<br/>');
//   };

//   return (
//     <div style={{ display: "flex", flexDirection: "column", height: "100vh", position: "relative", overflow: "hidden" }}>
//       <div className="bg-grid" />
//       <div className="orb orb-1" style={{ opacity: 0.6 }} />
//       <div className="orb orb-2" style={{ opacity: 0.5 }} />

//       {/* Header */}
//       <header ref={headerRef} className="glass" style={{
//         display: "flex", alignItems: "center", justifyContent: "space-between",
//         padding: "0 24px", height: "60px", borderRadius: 0,
//         borderLeft: "none", borderRight: "none", borderTop: "none",
//         position: "relative", zIndex: 10, flexShrink: 0,
//       }}>
//         <div style={{ display: "flex", alignItems: "center", gap: "16px" }}>
//           <button onClick={() => setSidebarOpen(!sidebarOpen)} style={{ background: "none", border: "none", color: "var(--text-secondary)", cursor: "pointer", padding: "8px", borderRadius: "8px", transition: "all 0.2s", fontSize: "18px" }}
//             onMouseEnter={(e) => e.target.style.color = "var(--text-primary)"}
//             onMouseLeave={(e) => e.target.style.color = "var(--text-secondary)"}>☰</button>
//           <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
//             <span style={{ fontSize: "20px" }}>🤖</span>
//             <span style={{ fontFamily: "Syne, sans-serif", fontWeight: 700, fontSize: "16px" }}>
//               Ollama <span style={{ color: "var(--accent)" }}>Agent</span>
//             </span>
//           </div>
//         </div>

//         <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
//           <select value={model} onChange={(e) => setModel(e.target.value)} style={{ background: "rgba(255,255,255,0.05)", border: "1px solid var(--glass-border)", borderRadius: "8px", color: "var(--text-primary)", padding: "6px 12px", fontSize: "13px", fontFamily: "DM Sans, sans-serif", cursor: "pointer", outline: "none" }}>
//             {availableModels.map(m => <option key={m} value={m} style={{ background: "#0a0f1e" }}>{m}</option>)}
//           </select>

//           {voiceSupported && (
//             <button onClick={() => { setVoiceEnabled(!voiceEnabled); if (isSpeaking) stopSpeaking(); }} style={{ display: "flex", alignItems: "center", gap: "6px", background: voiceEnabled ? "rgba(0,229,160,0.12)" : "rgba(255,255,255,0.05)", border: `1px solid ${voiceEnabled ? "rgba(0,229,160,0.3)" : "var(--glass-border)"}`, borderRadius: "8px", color: voiceEnabled ? "var(--success)" : "var(--text-secondary)", padding: "6px 12px", fontSize: "12px", cursor: "pointer", fontFamily: "DM Sans, sans-serif", transition: "all 0.25s" }}>
//               {voiceEnabled ? "🔊 Voice ON" : "🔇 Voice OFF"}
//             </button>
//           )}

//           <div style={{ display: "flex", alignItems: "center", gap: "6px" }}>
//             <div style={{ width: 8, height: 8, borderRadius: "50%", background: "var(--success)", boxShadow: "0 0 8px var(--success)", animation: "typingPulse 2s ease-in-out infinite" }} />
//             <span style={{ fontSize: "12px", color: "var(--text-secondary)" }}>Ollama Online</span>
//           </div>

//           <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
//             <div style={{ width: 32, height: 32, borderRadius: "50%", background: "linear-gradient(135deg, var(--accent), var(--accent-2))", display: "flex", alignItems: "center", justifyContent: "center", fontSize: "13px", fontWeight: 700 }}>
//               {user?.username?.[0]?.toUpperCase()}
//             </div>
//             <span style={{ fontSize: "13px", color: "var(--text-secondary)" }}>{user?.username}</span>
//           </div>

//           <button onClick={handleLogout} style={{ background: "rgba(255,77,109,0.1)", border: "1px solid rgba(255,77,109,0.2)", borderRadius: "8px", color: "var(--danger)", padding: "6px 14px", fontSize: "13px", cursor: "pointer", fontFamily: "DM Sans, sans-serif", transition: "all 0.2s" }}
//             onMouseEnter={(e) => { e.target.style.background = "rgba(255,77,109,0.2)"; }}
//             onMouseLeave={(e) => { e.target.style.background = "rgba(255,77,109,0.1)"; }}>
//             Logout
//           </button>
//         </div>
//       </header>

//       {/* Body */}
//       <div style={{ display: "flex", flex: 1, overflow: "hidden", position: "relative", zIndex: 1 }}>

//         {/* Sidebar */}
//         {sidebarOpen && (
//           <aside ref={sidebarRef} className="glass" style={{ width: 260, borderRadius: 0, borderTop: "none", borderBottom: "none", borderLeft: "none", display: "flex", flexDirection: "column", flexShrink: 0, overflow: "hidden" }}>
//             <div style={{ padding: "16px" }}>
//               <button onClick={newChat} style={{ width: "100%", padding: "10px 14px", background: "linear-gradient(135deg, rgba(0,212,255,0.15), rgba(123,94,167,0.15))", border: "1px solid rgba(0,212,255,0.2)", borderRadius: "10px", color: "var(--accent)", fontFamily: "Syne, sans-serif", fontWeight: 600, fontSize: "14px", cursor: "pointer", display: "flex", alignItems: "center", gap: "8px", justifyContent: "center", transition: "all 0.2s" }}
//                 onMouseEnter={(e) => e.currentTarget.style.background = "linear-gradient(135deg, rgba(0,212,255,0.22), rgba(123,94,167,0.22))"}
//                 onMouseLeave={(e) => e.currentTarget.style.background = "linear-gradient(135deg, rgba(0,212,255,0.15), rgba(123,94,167,0.15))"}>
//                 + New Chat
//               </button>
//             </div>
//             <div style={{ padding: "0 16px 8px", color: "var(--text-muted)", fontSize: "11px", fontWeight: 600, letterSpacing: "1px", textTransform: "uppercase" }}>Recent</div>
//             <div style={{ flex: 1, overflowY: "auto", padding: "0 8px 16px" }}>
//               {chatHistory.length === 0 && <p style={{ color: "var(--text-muted)", fontSize: "13px", textAlign: "center", padding: "20px 8px" }}>No chats yet. Start a conversation!</p>}
//               {chatHistory.map(chat => (
//                 <div key={chat._id} className={`sidebar-item ${currentChatId === chat._id ? "active" : ""}`} onClick={() => loadChat(chat._id)} style={{ display: "flex", alignItems: "center", justifyContent: "space-between", gap: "8px", marginBottom: "4px" }}>
//                   <div style={{ overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap", flex: 1 }}>💬 {chat.title}</div>
//                   <button onClick={(e) => deleteChat(e, chat._id)} style={{ background: "none", border: "none", color: "var(--text-muted)", cursor: "pointer", fontSize: "14px", padding: "2px", flexShrink: 0, borderRadius: "4px", transition: "color 0.2s" }}
//                     onMouseEnter={(e) => e.target.style.color = "var(--danger)"}
//                     onMouseLeave={(e) => e.target.style.color = "var(--text-muted)"}>×</button>
//                 </div>
//               ))}
//             </div>
//           </aside>
//         )}

//         {/* Chat Area */}
//         <div id="chat-area" style={{ flex: 1, display: "flex", flexDirection: "column", overflow: "hidden" }}>

//           {/* Messages */}
//           <div style={{ flex: 1, overflowY: "auto", padding: "24px", display: "flex", flexDirection: "column", gap: "16px" }}>
//             {messages.map((msg, i) => (
//               <div key={msg.id || i} className="fade-up" style={{ display: "flex", flexDirection: "column", alignItems: msg.role === "user" ? "flex-end" : "flex-start", animationDelay: `${i * 0.05}s` }}>
//                 <div style={{ display: "flex", alignItems: "flex-start", gap: "10px", maxWidth: "75%", flexDirection: msg.role === "user" ? "row-reverse" : "row" }}>
//                   <div style={{ width: 32, height: 32, borderRadius: "10px", flexShrink: 0, background: msg.role === "user" ? "linear-gradient(135deg, var(--accent), var(--accent-2))" : "rgba(255,255,255,0.06)", border: msg.role === "user" ? "none" : "1px solid var(--glass-border)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: "14px" }}>
//                     {msg.role === "user" ? user?.username?.[0]?.toUpperCase() : "🤖"}
//                   </div>
//                   <div className={msg.role === "user" ? "msg-user" : "msg-ai"} style={{ padding: "12px 16px", borderRadius: "14px", borderTopRightRadius: msg.role === "user" ? "4px" : "14px", borderTopLeftRadius: msg.role === "assistant" ? "4px" : "14px", fontSize: "15px", lineHeight: 1.6, color: "var(--text-primary)", position: "relative" }}>
//                     <div dangerouslySetInnerHTML={{ __html: renderMarkdown(msg.content || "") }} />
//                     {msg.role === "assistant" && msg.content && (
//                       <button onClick={() => isSpeaking ? stopSpeaking() : speakText(msg.content)} style={{ position: "absolute", bottom: "6px", right: "8px", background: "none", border: "none", cursor: "pointer", fontSize: "13px", opacity: 0.4, transition: "opacity 0.2s", padding: "2px" }}
//                         onMouseEnter={(e) => e.target.style.opacity = "1"}
//                         onMouseLeave={(e) => e.target.style.opacity = "0.4"}>
//                         {isSpeaking ? "⏹️" : "🔊"}
//                       </button>
//                     )}
//                   </div>
//                 </div>
//               </div>
//             ))}

//             {isTyping && (
//               <div className="fade-in" style={{ display: "flex", alignItems: "flex-start", gap: "10px" }}>
//                 <div style={{ width: 32, height: 32, borderRadius: "10px", background: "rgba(255,255,255,0.06)", border: "1px solid var(--glass-border)", display: "flex", alignItems: "center", justifyContent: "center" }}>🤖</div>
//                 <div className="msg-ai" style={{ padding: "12px 16px", borderRadius: "14px", borderTopLeftRadius: "4px", display: "flex", alignItems: "center", gap: "6px" }}>
//                   <div className="typing-dot" /><div className="typing-dot" /><div className="typing-dot" />
//                 </div>
//               </div>
//             )}
//             <div ref={messagesEndRef} />
//           </div>

//           {/* 🎤 Listening bar */}
//           {isListening && (
//             <div style={{ margin: "0 16px 8px", padding: "10px 16px", background: "rgba(0,212,255,0.08)", border: "1px solid rgba(0,212,255,0.25)", borderRadius: "10px", display: "flex", alignItems: "center", gap: "10px" }}>
//               <div style={{ display: "flex", gap: "3px", alignItems: "center" }}>
//                 {[1,2,3,4,5].map(i => <div key={i} style={{ width: 3, borderRadius: "3px", background: "var(--accent)", height: `${8 + i * 3}px`, animation: `typingPulse ${0.5 + i * 0.1}s ease-in-out infinite`, animationDelay: `${i * 0.1}s` }} />)}
//               </div>
//               <span style={{ fontSize: "13px", color: "var(--accent)", flex: 1 }}>🎤 Listening... <span style={{ color: "var(--text-secondary)" }}>{transcript || "speak now"}</span></span>
//               <button onClick={stopListening} style={{ background: "rgba(255,77,109,0.1)", border: "1px solid rgba(255,77,109,0.2)", borderRadius: "6px", color: "var(--danger)", padding: "4px 10px", fontSize: "12px", cursor: "pointer" }}>Cancel</button>
//             </div>
//           )}

//           {/* 🔊 Speaking bar */}
//           {isSpeaking && (
//             <div style={{ margin: "0 16px 8px", padding: "10px 16px", background: "rgba(0,229,160,0.06)", border: "1px solid rgba(0,229,160,0.2)", borderRadius: "10px", display: "flex", alignItems: "center", gap: "10px" }}>
//               <span style={{ fontSize: "13px", color: "var(--success)", flex: 1 }}>🔊 Speaking response...</span>
//               <button onClick={stopSpeaking} style={{ background: "rgba(255,77,109,0.1)", border: "1px solid rgba(255,77,109,0.2)", borderRadius: "6px", color: "var(--danger)", padding: "4px 10px", fontSize: "12px", cursor: "pointer" }}>Stop</button>
//             </div>
//           )}

//           {/* 📎 Attachment preview bar */}
//           {(attachedFile || isReadingFile) && (
//             <div id="attach-preview" style={{ margin: "0 16px 8px", padding: "10px 16px", background: "rgba(123,94,167,0.08)", border: "1px solid rgba(123,94,167,0.25)", borderRadius: "10px", display: "flex", alignItems: "center", gap: "12px" }}>
//               {isReadingFile ? (
//                 <>
//                   <div style={{ display: "flex", gap: "4px", alignItems: "center" }}>
//                     <div className="typing-dot" style={{ background: "var(--accent-2)" }} />
//                     <div className="typing-dot" style={{ background: "var(--accent-2)" }} />
//                     <div className="typing-dot" style={{ background: "var(--accent-2)" }} />
//                   </div>
//                   <span style={{ fontSize: "13px", color: "var(--text-secondary)" }}>Reading file...</span>
//                 </>
//               ) : (
//                 <>
//                   <span style={{ fontSize: "22px" }}>{getFileIcon(attachedFile.name)}</span>
//                   <div style={{ flex: 1, minWidth: 0 }}>
//                     <div style={{ fontSize: "13px", color: "var(--text-primary)", fontWeight: 500, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{attachedFile.name}</div>
//                     <div style={{ fontSize: "11px", color: "var(--text-muted)", marginTop: "2px" }}>{attachedFile.size} · Ready to analyze</div>
//                   </div>
//                   <div style={{ display: "flex", alignItems: "center", gap: "6px" }}>
//                     <div style={{ width: 6, height: 6, borderRadius: "50%", background: "var(--success)", boxShadow: "0 0 6px var(--success)" }} />
//                     <span style={{ fontSize: "11px", color: "var(--success)" }}>Attached</span>
//                   </div>
//                   <button onClick={removeAttachment} style={{ background: "rgba(255,77,109,0.1)", border: "1px solid rgba(255,77,109,0.2)", borderRadius: "6px", color: "var(--danger)", padding: "4px 10px", fontSize: "12px", cursor: "pointer", flexShrink: 0 }}>Remove</button>
//                 </>
//               )}
//             </div>
//           )}

//           {/* Hidden file input */}
//           <input
//             ref={fileInputRef}
//             type="file"
//             accept={ACCEPTED_TYPES}
//             onChange={handleFileAttach}
//             style={{ display: "none" }}
//           />

//           {/* Input box */}
//           <div className="glass" style={{ margin: "0 16px 16px", borderRadius: "14px", overflow: "hidden", flexShrink: 0 }}>
//             <div style={{ display: "flex", alignItems: "flex-end", gap: "10px", padding: "12px 16px" }}>

//               {/* 📎 Attach button — LEFT SIDE */}
//               <button
//                 onClick={() => fileInputRef.current?.click()}
//                 disabled={isTyping || isReadingFile}
//                 title="Attach a document (PDF, TXT, CSV, JSON, code files...)"
//                 style={{
//                   width: 42, height: 42, borderRadius: "10px", border: "none", cursor: "pointer",
//                   background: attachedFile
//                     ? "linear-gradient(135deg, rgba(123,94,167,0.4), rgba(123,94,167,0.2))"
//                     : "rgba(255,255,255,0.06)",
//                   display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0,
//                   transition: "all 0.25s", fontSize: "18px",
//                   border: attachedFile ? "1px solid rgba(123,94,167,0.5)" : "1px solid transparent",
//                   boxShadow: attachedFile ? "0 0 14px rgba(123,94,167,0.3)" : "none",
//                 }}
//                 onMouseEnter={(e) => { if (!attachedFile) e.currentTarget.style.background = "rgba(255,255,255,0.1)"; }}
//                 onMouseLeave={(e) => { if (!attachedFile) e.currentTarget.style.background = "rgba(255,255,255,0.06)"; }}
//               >
//                 📎
//               </button>

//               {/* Text input */}
//               <textarea
//                 ref={inputRef}
//                 value={input}
//                 onChange={(e) => setInput(e.target.value)}
//                 onKeyDown={handleKey}
//                 placeholder={
//                   isListening ? "🎤 Listening..." :
//                   attachedFile ? `Ask anything about "${attachedFile.name}"...` :
//                   "Ask me anything... or attach a 📎 document"
//                 }
//                 rows={1}
//                 style={{ flex: 1, background: "none", border: "none", outline: "none", resize: "none", color: "var(--text-primary)", fontFamily: "DM Sans, sans-serif", fontSize: "15px", lineHeight: 1.6, maxHeight: "120px", overflowY: "auto", padding: "4px 0" }}
//                 onInput={(e) => { e.target.style.height = "auto"; e.target.style.height = Math.min(e.target.scrollHeight, 120) + "px"; }}
//               />

//               {/* 🎤 Mic button */}
//               {voiceSupported && (
//                 <button id="mic-btn" onClick={isListening ? stopListening : startListening} disabled={isTyping} title={isListening ? "Stop listening" : "Speak your question"} style={{ width: 42, height: 42, borderRadius: "10px", border: "none", cursor: "pointer", background: isListening ? "linear-gradient(135deg, #ff4d6d, #ff6b6b)" : "rgba(255,255,255,0.06)", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0, transition: "all 0.25s", fontSize: "18px", boxShadow: isListening ? "0 0 20px rgba(255,77,109,0.4)" : "none" }}>
//                   {isListening ? "⏹" : "🎤"}
//                 </button>
//               )}

//               {/* ↑ Send button */}
//               <button id="send-btn" onClick={sendMessage} disabled={!input.trim() || isTyping} style={{ width: 42, height: 42, borderRadius: "10px", border: "none", cursor: "pointer", background: input.trim() && !isTyping ? "linear-gradient(135deg, var(--accent), var(--accent-2))" : "rgba(255,255,255,0.06)", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0, transition: "all 0.25s", fontSize: "18px" }}>
//                 {isTyping ? "⏳" : "↑"}
//               </button>
//             </div>

//             {/* Bottom bar */}
//             <div style={{ padding: "0 16px 10px", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
//               <span style={{ fontSize: "11px", color: "var(--text-muted)" }}>
//                 Model: <span style={{ color: "var(--accent)" }}>{model}</span>
//                 {attachedFile && <span style={{ marginLeft: "8px", color: "rgba(123,94,167,0.8)" }}>· 📎 {attachedFile.name}</span>}
//                 {voiceSupported && !attachedFile && <span style={{ marginLeft: "8px" }}>· {voiceEnabled ? "🔊 Auto-speak ON" : "🎤 Voice ready"}</span>}
//               </span>
//               <span style={{ fontSize: "11px", color: "var(--text-muted)" }}>
//                 {attachedFile ? `📄 Doc attached` : `${input.length} chars`}
//               </span>
//             </div>
//           </div>
//         </div>
//       </div>

//       {/* Footer */}
//       <div style={{ textAlign: "center", padding: "8px", color: "var(--text-muted)", fontSize: "11px", borderTop: "1px solid var(--glass-border)", flexShrink: 0, position: "relative", zIndex: 1 }}>
//         Created by <span style={{ color: "var(--accent)", fontWeight: 600 }}>@techwithburhan</span> · Offline AI powered by Ollama
//       </div>
//     </div>
//   );
// }

import React, { useState, useEffect, useRef } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";
import { gsap } from "gsap";
import { useAuth } from "../context/AuthContext";

const MODELS = ["llama2", "mistral", "gemma", "phi", "codellama", "llama3"];

// 🧠 System persona — acts as a DevOps AI engineer
const SYSTEM_PERSONA = `You are an expert AI assistant with deep knowledge in DevOps, Cloud Computing (AWS, GCP, Azure), Kubernetes, Docker, Terraform, CI/CD pipelines, Linux, Networking, Python, and software engineering. 

Before answering any question, you MUST follow this exact format:

<think>
[Write your internal reasoning here. Analyze what the user is asking, identify the key concepts, think about the best approach, consider edge cases, and plan your response. Be thorough in your thinking — 2 to 5 sentences.]
</think>

[Then write your actual response here — clear, structured, and helpful.]

Always be precise, practical, and give real-world examples when relevant.`;

// 📄 Read file contents as text
const readFileAsText = (file) => {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    if (file.type === "application/pdf") {
      reader.onload = async (e) => {
        try {
          const buffer = e.target.result;
          const bytes = new Uint8Array(buffer);
          let text = "";
          for (let i = 0; i < bytes.length; i++) {
            const b = bytes[i];
            if (b >= 32 && b < 127) text += String.fromCharCode(b);
            else if (b === 10 || b === 13) text += " ";
          }
          const words = text.split(/\s+/).filter(w => w.length > 2 && /[a-zA-Z]/.test(w));
          resolve(words.join(" ").substring(0, 8000) || "Could not extract text from PDF.");
        } catch (err) { reject(err); }
      };
      reader.onerror = reject;
      reader.readAsArrayBuffer(file);
    } else {
      reader.onload = (e) => resolve(e.target.result.substring(0, 8000));
      reader.onerror = reject;
      reader.readAsText(file);
    }
  });
};

const ACCEPTED_TYPES = ".txt,.md,.csv,.json,.js,.py,.html,.css,.ts,.pdf,.xml,.yaml,.yml,.log";

// 🧠 Parse <think>...</think> from response
const parseThinkingResponse = (text) => {
  const thinkMatch = text.match(/<think>([\s\S]*?)<\/think>/i);
  const thinking = thinkMatch ? thinkMatch[1].trim() : null;
  const response = text.replace(/<think>[\s\S]*?<\/think>/i, "").trim();
  return { thinking, response };
};

// Thinking phrases that rotate while AI processes
const THINKING_PHRASES = [
  "Analyzing your question...",
  "Processing context...",
  "Thinking through this...",
  "Considering best approach...",
  "Evaluating options...",
  "Reasoning about this...",
  "Connecting the dots...",
  "Formulating response...",
];

export default function Chat() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState("");
  const [isTyping, setIsTyping] = useState(false);
  const [chatHistory, setChatHistory] = useState([]);
  const [currentChatId, setCurrentChatId] = useState(null);
  const [model, setModel] = useState("llama2:latest");
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const [availableModels, setAvailableModels] = useState(MODELS);

  // 🎤 Voice states
  const [isListening, setIsListening] = useState(false);
  const [isSpeaking, setIsSpeaking] = useState(false);
  const [voiceEnabled, setVoiceEnabled] = useState(false);
  const [transcript, setTranscript] = useState("");
  const [voiceSupported, setVoiceSupported] = useState(false);

  // 📎 Attachment states
  const [attachedFile, setAttachedFile] = useState(null);
  const [isReadingFile, setIsReadingFile] = useState(false);

  // 🧠 Thinking states
  const [thinkingPhrase, setThinkingPhrase] = useState("");
  const [thinkingPhraseIdx, setThinkingPhraseIdx] = useState(0);
  const [expandedThinking, setExpandedThinking] = useState({});

  const messagesEndRef = useRef(null);
  const inputRef = useRef(null);
  const sidebarRef = useRef(null);
  const headerRef = useRef(null);
  const recognitionRef = useRef(null);
  const synthRef = useRef(window.speechSynthesis);
  const fileInputRef = useRef(null);
  const thinkingIntervalRef = useRef(null);

  useEffect(() => {
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
    if (SpeechRecognition) {
      setVoiceSupported(true);
      const recognition = new SpeechRecognition();
      recognition.continuous = false;
      recognition.interimResults = true;
      recognition.lang = "en-US";
      recognition.onstart = () => { setIsListening(true); setTranscript(""); };
      recognition.onresult = (event) => {
        let interim = "", final = "";
        for (let i = event.resultIndex; i < event.results.length; i++) {
          const t = event.results[i][0].transcript;
          event.results[i].isFinal ? (final += t) : (interim += t);
        }
        setInput(final || interim);
        setTranscript(final || interim);
      };
      recognition.onend = () => {
        setIsListening(false);
        if (recognitionRef.current._shouldSend) {
          recognitionRef.current._shouldSend = false;
          setTimeout(() => { document.getElementById("send-btn")?.click(); }, 300);
        }
      };
      recognition.onerror = (e) => {
        setIsListening(false);
        if (e.error === "not-allowed") alert("Microphone access denied. Please allow microphone in browser settings.");
      };
      recognitionRef.current = recognition;
    }

    const tl = gsap.timeline();
    tl.fromTo(headerRef.current, { opacity: 0, y: -20 }, { opacity: 1, y: 0, duration: 0.5, ease: "power2.out" });
    if (sidebarRef.current) tl.fromTo(sidebarRef.current, { opacity: 0, x: -30 }, { opacity: 1, x: 0, duration: 0.5, ease: "power2.out" }, "-=0.3");

    fetchHistory();
    fetchModels();
    setMessages([{
      role: "assistant",
      content: `Hello **${user?.username}**! 👋 I'm your AI assistant powered by **Ollama**. I think before I answer — you'll see my reasoning process before every response. You can type, speak 🎤, or attach a document 📎!`,
      id: Date.now(),
    }]);

    return () => {
      recognitionRef.current?.abort();
      synthRef.current?.cancel();
      if (thinkingIntervalRef.current) clearInterval(thinkingIntervalRef.current);
    };
  }, []);

  useEffect(() => { scrollToBottom(); }, [messages, isTyping]);

  const scrollToBottom = () => messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });

  // 🧠 Start rotating thinking phrases
  const startThinkingAnimation = () => {
    setThinkingPhrase(THINKING_PHRASES[0]);
    let idx = 0;
    thinkingIntervalRef.current = setInterval(() => {
      idx = (idx + 1) % THINKING_PHRASES.length;
      setThinkingPhrase(THINKING_PHRASES[idx]);
    }, 1800);
  };

  const stopThinkingAnimation = () => {
    if (thinkingIntervalRef.current) {
      clearInterval(thinkingIntervalRef.current);
      thinkingIntervalRef.current = null;
    }
    setThinkingPhrase("");
  };

  // 📎 Handle file attachment
  const handleFileAttach = async (e) => {
    const file = e.target.files[0];
    if (!file) return;
    e.target.value = "";
    const maxSize = 5 * 1024 * 1024;
    if (file.size > maxSize) { alert("File too large. Please attach files under 5MB."); return; }
    setIsReadingFile(true);
    gsap.fromTo("#attach-preview", { opacity: 0, y: 10 }, { opacity: 1, y: 0, duration: 0.3 });
    try {
      const content = await readFileAsText(file);
      setAttachedFile({ name: file.name, type: file.type || "text/plain", size: (file.size / 1024).toFixed(1) + " KB", content });
    } catch (err) {
      console.error("File read error:", err);
      alert("Could not read this file. Please try a different format.");
    } finally { setIsReadingFile(false); }
  };

  const removeAttachment = () => {
    setAttachedFile(null);
    gsap.to("#attach-preview", { opacity: 0, y: 10, duration: 0.2 });
  };

  // 🎤 Voice
  const startListening = () => {
    if (!recognitionRef.current || isListening) return;
    synthRef.current?.cancel(); setIsSpeaking(false);
    recognitionRef.current._shouldSend = true;
    recognitionRef.current.start();
    gsap.to("#mic-btn", { scale: 1.15, duration: 0.2, yoyo: true, repeat: -1, ease: "power1.inOut" });
  };

  const stopListening = () => {
    if (recognitionRef.current && isListening) {
      recognitionRef.current._shouldSend = false;
      recognitionRef.current.stop();
      gsap.killTweensOf("#mic-btn");
      gsap.to("#mic-btn", { scale: 1, duration: 0.2 });
    }
  };

  const speakText = (text) => {
    if (!voiceEnabled || !synthRef.current) return;
    const clean = text.replace(/\*\*(.*?)\*\*/g, "$1").replace(/`(.*?)`/g, "$1").replace(/<[^>]*>/g, "").replace(/[🎤🔊🤖👋❌📎🧠]/g, "");
    synthRef.current.cancel();
    const utterance = new SpeechSynthesisUtterance(clean);
    utterance.rate = 1.0; utterance.pitch = 1.0; utterance.volume = 1.0;
    const voices = synthRef.current.getVoices();
    const preferred = voices.find(v => v.name.includes("Google") || v.lang === "en-US");
    if (preferred) utterance.voice = preferred;
    utterance.onstart = () => setIsSpeaking(true);
    utterance.onend = () => setIsSpeaking(false);
    utterance.onerror = () => setIsSpeaking(false);
    synthRef.current.speak(utterance);
  };

  const stopSpeaking = () => { synthRef.current?.cancel(); setIsSpeaking(false); };

  const fetchHistory = async () => {
    try {
      const res = await axios.get("http://localhost:5005/api/chat/history");
      setChatHistory(res.data.chats || []);
    } catch (e) { console.error(e); }
  };

  const fetchModels = async () => {
    try {
      const res = await axios.get("http://localhost:5005/api/chat/models/list");
      if (res.data.models?.length > 0) {
        setAvailableModels(res.data.models.map(m => m.name));
        setModel(res.data.models[0].name);
      }
    } catch (e) { }
  };

  const sendMessage = async () => {
    if (!input.trim() || isTyping) return;

    let promptMessage = input.trim();
    let displayMessage = input.trim();

    if (attachedFile) {
      promptMessage = `I have attached a file named "${attachedFile.name}". Here is its content:\n\n---\n${attachedFile.content}\n---\n\nBased on this document, please answer: ${input.trim()}`;
      displayMessage = `📎 **${attachedFile.name}**\n${input.trim()}`;
    }

    // 🧠 Inject system persona into the prompt
    const fullPrompt = `${SYSTEM_PERSONA}\n\nUser question: ${promptMessage}`;

    const userMsg = { role: "user", content: displayMessage, id: Date.now() };
    setMessages(prev => [...prev, userMsg]);
    setInput("");
    setTranscript("");
    setAttachedFile(null);
    setIsTyping(true);

    // Start thinking animation
    startThinkingAnimation();

    gsap.killTweensOf("#mic-btn");
    gsap.to("#mic-btn", { scale: 1, duration: 0.1 });
    gsap.to("#send-btn", { scale: 0.85, duration: 0.1, yoyo: true, repeat: 1 });

    try {
      const token = localStorage.getItem("token");
      const response = await fetch("http://localhost:5005/api/chat/message", {
        method: "POST",
        headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
        body: JSON.stringify({ message: fullPrompt, chatId: currentChatId, model }),
      });

      if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);

      const aiMsgId = Date.now() + 1;
      // Add a message slot — will be parsed when done
      setMessages(prev => [...prev, { role: "assistant", content: "", thinking: null, isStreaming: true, id: aiMsgId }]);
      setIsTyping(false);
      stopThinkingAnimation();

      const reader = response.body.getReader();
      const decoder = new TextDecoder();
      let fullAiResponse = "";

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        const text = decoder.decode(value);
        const lines = text.split("\n").filter(l => l.startsWith("data: "));
        for (const line of lines) {
          try {
            const data = JSON.parse(line.slice(6));
            if (data.token) {
              fullAiResponse += data.token;
              // Parse thinking in real-time
              const { thinking, response } = parseThinkingResponse(fullAiResponse);
              setMessages(prev => prev.map(m => m.id === aiMsgId
                ? { ...m, content: response, thinking, isStreaming: true }
                : m
              ));
            }
            if (data.done) {
              // Final parse — mark streaming done
              const { thinking, response } = parseThinkingResponse(fullAiResponse);
              setMessages(prev => prev.map(m => m.id === aiMsgId
                ? { ...m, content: response, thinking, isStreaming: false }
                : m
              ));
              fetchHistory();
              if (voiceEnabled && response) speakText(response);
            }
            if (data.error) setMessages(prev => prev.map(m => m.id === aiMsgId ? { ...m, content: "❌ " + data.error, isStreaming: false } : m));
          } catch { }
        }
      }
    } catch (err) {
      stopThinkingAnimation();
      setIsTyping(false);
      setMessages(prev => [...prev, { role: "assistant", content: "❌ Error connecting to Ollama. Make sure Ollama is running on `http://localhost:11434`", id: Date.now() }]);
    }
  };

  const loadChat = async (chatId) => {
    try {
      const res = await axios.get(`http://localhost:5005/api/chat/${chatId}`);
      setMessages(res.data.chat.messages.map((m, i) => ({ ...m, id: i })));
      setCurrentChatId(chatId);
    } catch (e) { console.error(e); }
  };

  const newChat = () => {
    synthRef.current?.cancel();
    stopThinkingAnimation();
    setAttachedFile(null);
    setMessages([{ role: "assistant", content: `Hello **${user?.username}**! 👋 Starting a new conversation. What's on your mind?`, id: Date.now() }]);
    setCurrentChatId(null);
    gsap.fromTo("#chat-area", { opacity: 0 }, { opacity: 1, duration: 0.4 });
  };

  const deleteChat = async (e, chatId) => {
    e.stopPropagation();
    try {
      await axios.delete(`http://localhost:5005/api/chat/${chatId}`);
      setChatHistory(prev => prev.filter(c => c._id !== chatId));
      if (currentChatId === chatId) newChat();
    } catch (e) { console.error(e); }
  };

  const handleLogout = () => {
    synthRef.current?.cancel();
    gsap.to("body", { opacity: 0, duration: 0.3, onComplete: () => { logout(); navigate("/login"); } });
  };

  const handleKey = (e) => {
    if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); sendMessage(); }
  };

  const getFileIcon = (name) => {
    const ext = name.split(".").pop().toLowerCase();
    const icons = { pdf: "📄", js: "📜", py: "🐍", html: "🌐", css: "🎨", json: "📋", csv: "📊", md: "📝", txt: "📃", ts: "📘" };
    return icons[ext] || "📎";
  };

  const renderMarkdown = (text) => {
    if (!text) return "";
    return text
      .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
      .replace(/`(.*?)`/g, '<code style="background:rgba(0,212,255,0.1);padding:2px 6px;border-radius:4px;font-family:monospace;font-size:13px;color:var(--accent)">$1</code>')
      .replace(/\n/g, '<br/>');
  };

  const toggleThinking = (msgId) => {
    setExpandedThinking(prev => ({ ...prev, [msgId]: !prev[msgId] }));
  };

  // 🧠 Thinking block component
  const ThinkingBlock = ({ msg }) => {
    const isExpanded = expandedThinking[msg.id];
    const hasThinking = msg.thinking && msg.thinking.length > 0;
    const isStreaming = msg.isStreaming;

    // Show live thinking animation while streaming and no think tag yet
    if (isStreaming && !hasThinking) {
      return (
        <div style={{
          marginBottom: "8px",
          background: "rgba(123,94,167,0.06)",
          border: "1px solid rgba(123,94,167,0.2)",
          borderRadius: "10px",
          padding: "10px 14px",
          display: "flex", alignItems: "center", gap: "10px",
        }}>
          {/* Brain pulse */}
          <div style={{ position: "relative", width: 20, height: 20, flexShrink: 0 }}>
            <div style={{ position: "absolute", inset: 0, borderRadius: "50%", background: "rgba(123,94,167,0.3)", animation: "typingPulse 1s ease-in-out infinite" }} />
            <div style={{ position: "absolute", inset: 3, borderRadius: "50%", background: "rgba(123,94,167,0.6)" }} />
          </div>
          <span style={{ fontSize: "13px", color: "rgba(123,94,167,0.9)", fontStyle: "italic" }}>
            🧠 {thinkingPhrase || "Thinking..."}
          </span>
          <div style={{ display: "flex", gap: "3px", marginLeft: "auto" }}>
            {[0,1,2].map(i => (
              <div key={i} style={{ width: 4, height: 4, borderRadius: "50%", background: "rgba(123,94,167,0.7)", animation: `typingPulse 0.8s ease-in-out infinite`, animationDelay: `${i * 0.2}s` }} />
            ))}
          </div>
        </div>
      );
    }

    // Show collapsible thinking block after streaming
    if (hasThinking) {
      return (
        <div style={{ marginBottom: "8px" }}>
          <button
            onClick={() => toggleThinking(msg.id)}
            style={{
              display: "flex", alignItems: "center", gap: "8px",
              background: "rgba(123,94,167,0.08)",
              border: "1px solid rgba(123,94,167,0.2)",
              borderRadius: isExpanded ? "10px 10px 0 0" : "10px",
              padding: "8px 14px", cursor: "pointer", width: "100%",
              transition: "all 0.2s",
            }}
          >
            <span style={{ fontSize: "14px" }}>🧠</span>
            <span style={{ fontSize: "12px", color: "rgba(123,94,167,0.9)", fontWeight: 600, flex: 1, textAlign: "left" }}>
              Thought Process
            </span>
            <span style={{ fontSize: "11px", color: "rgba(123,94,167,0.6)" }}>
              {isExpanded ? "▲ Hide" : "▼ Show"}
            </span>
          </button>
          {isExpanded && (
            <div style={{
              background: "rgba(123,94,167,0.04)",
              border: "1px solid rgba(123,94,167,0.15)",
              borderTop: "none",
              borderRadius: "0 0 10px 10px",
              padding: "12px 14px",
              fontSize: "13px",
              color: "rgba(200,180,240,0.8)",
              lineHeight: 1.7,
              fontStyle: "italic",
              animation: "fadeIn 0.2s ease",
            }}>
              <div dangerouslySetInnerHTML={{ __html: renderMarkdown(msg.thinking) }} />
            </div>
          )}
        </div>
      );
    }

    return null;
  };

  return (
    <div style={{ display: "flex", flexDirection: "column", height: "100vh", position: "relative", overflow: "hidden" }}>
      <div className="bg-grid" />
      <div className="orb orb-1" style={{ opacity: 0.6 }} />
      <div className="orb orb-2" style={{ opacity: 0.5 }} />

      {/* Header */}
      <header ref={headerRef} className="glass" style={{
        display: "flex", alignItems: "center", justifyContent: "space-between",
        padding: "0 24px", height: "60px", borderRadius: 0,
        borderLeft: "none", borderRight: "none", borderTop: "none",
        position: "relative", zIndex: 10, flexShrink: 0,
      }}>
        <div style={{ display: "flex", alignItems: "center", gap: "16px" }}>
          <button onClick={() => setSidebarOpen(!sidebarOpen)} style={{ background: "none", border: "none", color: "var(--text-secondary)", cursor: "pointer", padding: "8px", borderRadius: "8px", transition: "all 0.2s", fontSize: "18px" }}
            onMouseEnter={(e) => e.target.style.color = "var(--text-primary)"}
            onMouseLeave={(e) => e.target.style.color = "var(--text-secondary)"}>☰</button>
          <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
            <span style={{ fontSize: "20px" }}>🤖</span>
            <span style={{ fontFamily: "Syne, sans-serif", fontWeight: 700, fontSize: "16px" }}>
              Ollama <span style={{ color: "var(--accent)" }}>Agent</span>
            </span>
            {/* 🧠 Thinking badge */}
            <span style={{ fontSize: "10px", background: "rgba(123,94,167,0.2)", border: "1px solid rgba(123,94,167,0.3)", borderRadius: "20px", padding: "2px 8px", color: "rgba(180,150,230,0.9)", fontWeight: 600, letterSpacing: "0.5px" }}>
              🧠 REASONING
            </span>
          </div>
        </div>

        <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
          <select value={model} onChange={(e) => setModel(e.target.value)} style={{ background: "rgba(255,255,255,0.05)", border: "1px solid var(--glass-border)", borderRadius: "8px", color: "var(--text-primary)", padding: "6px 12px", fontSize: "13px", fontFamily: "DM Sans, sans-serif", cursor: "pointer", outline: "none" }}>
            {availableModels.map(m => <option key={m} value={m} style={{ background: "#0a0f1e" }}>{m}</option>)}
          </select>

          {voiceSupported && (
            <button onClick={() => { setVoiceEnabled(!voiceEnabled); if (isSpeaking) stopSpeaking(); }} style={{ display: "flex", alignItems: "center", gap: "6px", background: voiceEnabled ? "rgba(0,229,160,0.12)" : "rgba(255,255,255,0.05)", border: `1px solid ${voiceEnabled ? "rgba(0,229,160,0.3)" : "var(--glass-border)"}`, borderRadius: "8px", color: voiceEnabled ? "var(--success)" : "var(--text-secondary)", padding: "6px 12px", fontSize: "12px", cursor: "pointer", fontFamily: "DM Sans, sans-serif", transition: "all 0.25s" }}>
              {voiceEnabled ? "🔊 Voice ON" : "🔇 Voice OFF"}
            </button>
          )}

          <div style={{ display: "flex", alignItems: "center", gap: "6px" }}>
            <div style={{ width: 8, height: 8, borderRadius: "50%", background: "var(--success)", boxShadow: "0 0 8px var(--success)", animation: "typingPulse 2s ease-in-out infinite" }} />
            <span style={{ fontSize: "12px", color: "var(--text-secondary)" }}>Ollama Online</span>
          </div>

          <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
            <div style={{ width: 32, height: 32, borderRadius: "50%", background: "linear-gradient(135deg, var(--accent), var(--accent-2))", display: "flex", alignItems: "center", justifyContent: "center", fontSize: "13px", fontWeight: 700 }}>
              {user?.username?.[0]?.toUpperCase()}
            </div>
            <span style={{ fontSize: "13px", color: "var(--text-secondary)" }}>{user?.username}</span>
          </div>

          <button onClick={handleLogout} style={{ background: "rgba(255,77,109,0.1)", border: "1px solid rgba(255,77,109,0.2)", borderRadius: "8px", color: "var(--danger)", padding: "6px 14px", fontSize: "13px", cursor: "pointer", fontFamily: "DM Sans, sans-serif", transition: "all 0.2s" }}
            onMouseEnter={(e) => { e.target.style.background = "rgba(255,77,109,0.2)"; }}
            onMouseLeave={(e) => { e.target.style.background = "rgba(255,77,109,0.1)"; }}>
            Logout
          </button>
        </div>
      </header>

      {/* Body */}
      <div style={{ display: "flex", flex: 1, overflow: "hidden", position: "relative", zIndex: 1 }}>

        {/* Sidebar */}
        {sidebarOpen && (
          <aside ref={sidebarRef} className="glass" style={{ width: 260, borderRadius: 0, borderTop: "none", borderBottom: "none", borderLeft: "none", display: "flex", flexDirection: "column", flexShrink: 0, overflow: "hidden" }}>
            <div style={{ padding: "16px" }}>
              <button onClick={newChat} style={{ width: "100%", padding: "10px 14px", background: "linear-gradient(135deg, rgba(0,212,255,0.15), rgba(123,94,167,0.15))", border: "1px solid rgba(0,212,255,0.2)", borderRadius: "10px", color: "var(--accent)", fontFamily: "Syne, sans-serif", fontWeight: 600, fontSize: "14px", cursor: "pointer", display: "flex", alignItems: "center", gap: "8px", justifyContent: "center", transition: "all 0.2s" }}
                onMouseEnter={(e) => e.currentTarget.style.background = "linear-gradient(135deg, rgba(0,212,255,0.22), rgba(123,94,167,0.22))"}
                onMouseLeave={(e) => e.currentTarget.style.background = "linear-gradient(135deg, rgba(0,212,255,0.15), rgba(123,94,167,0.15))"}>
                + New Chat
              </button>
            </div>
            <div style={{ padding: "0 16px 8px", color: "var(--text-muted)", fontSize: "11px", fontWeight: 600, letterSpacing: "1px", textTransform: "uppercase" }}>Recent</div>
            <div style={{ flex: 1, overflowY: "auto", padding: "0 8px 16px" }}>
              {chatHistory.length === 0 && <p style={{ color: "var(--text-muted)", fontSize: "13px", textAlign: "center", padding: "20px 8px" }}>No chats yet. Start a conversation!</p>}
              {chatHistory.map(chat => (
                <div key={chat._id} className={`sidebar-item ${currentChatId === chat._id ? "active" : ""}`} onClick={() => loadChat(chat._id)} style={{ display: "flex", alignItems: "center", justifyContent: "space-between", gap: "8px", marginBottom: "4px" }}>
                  <div style={{ overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap", flex: 1 }}>💬 {chat.title}</div>
                  <button onClick={(e) => deleteChat(e, chat._id)} style={{ background: "none", border: "none", color: "var(--text-muted)", cursor: "pointer", fontSize: "14px", padding: "2px", flexShrink: 0, borderRadius: "4px", transition: "color 0.2s" }}
                    onMouseEnter={(e) => e.target.style.color = "var(--danger)"}
                    onMouseLeave={(e) => e.target.style.color = "var(--text-muted)"}>×</button>
                </div>
              ))}
            </div>
          </aside>
        )}

        {/* Chat Area */}
        <div id="chat-area" style={{ flex: 1, display: "flex", flexDirection: "column", overflow: "hidden" }}>

          {/* Messages */}
          <div style={{ flex: 1, overflowY: "auto", padding: "24px", display: "flex", flexDirection: "column", gap: "16px" }}>
            {messages.map((msg, i) => (
              <div key={msg.id || i} className="fade-up" style={{ display: "flex", flexDirection: "column", alignItems: msg.role === "user" ? "flex-end" : "flex-start", animationDelay: `${i * 0.05}s` }}>
                <div style={{ display: "flex", alignItems: "flex-start", gap: "10px", maxWidth: "80%", flexDirection: msg.role === "user" ? "row-reverse" : "row" }}>
                  <div style={{ width: 32, height: 32, borderRadius: "10px", flexShrink: 0, background: msg.role === "user" ? "linear-gradient(135deg, var(--accent), var(--accent-2))" : "rgba(255,255,255,0.06)", border: msg.role === "user" ? "none" : "1px solid var(--glass-border)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: "14px" }}>
                    {msg.role === "user" ? user?.username?.[0]?.toUpperCase() : "🤖"}
                  </div>

                  <div style={{ display: "flex", flexDirection: "column", flex: 1 }}>
                    {/* 🧠 Thinking block — only for assistant */}
                    {msg.role === "assistant" && <ThinkingBlock msg={msg} />}

                    {/* Message bubble */}
                    {(msg.content || msg.role === "user") && (
                      <div className={msg.role === "user" ? "msg-user" : "msg-ai"} style={{ padding: "12px 16px", borderRadius: "14px", borderTopRightRadius: msg.role === "user" ? "4px" : "14px", borderTopLeftRadius: msg.role === "assistant" ? "4px" : "14px", fontSize: "15px", lineHeight: 1.6, color: "var(--text-primary)", position: "relative" }}>
                        <div dangerouslySetInnerHTML={{ __html: renderMarkdown(msg.content || "") }} />
                        {/* Cursor while streaming */}
                        {msg.isStreaming && msg.content && (
                          <span style={{ display: "inline-block", width: 2, height: "1em", background: "var(--accent)", marginLeft: 2, animation: "typingPulse 0.7s ease-in-out infinite", verticalAlign: "text-bottom" }} />
                        )}
                        {msg.role === "assistant" && msg.content && !msg.isStreaming && (
                          <button onClick={() => isSpeaking ? stopSpeaking() : speakText(msg.content)} style={{ position: "absolute", bottom: "6px", right: "8px", background: "none", border: "none", cursor: "pointer", fontSize: "13px", opacity: 0.4, transition: "opacity 0.2s", padding: "2px" }}
                            onMouseEnter={(e) => e.target.style.opacity = "1"}
                            onMouseLeave={(e) => e.target.style.opacity = "0.4"}>
                            {isSpeaking ? "⏹️" : "🔊"}
                          </button>
                        )}
                      </div>
                    )}
                  </div>
                </div>
              </div>
            ))}

            {/* Main typing indicator (before streaming starts) */}
            {isTyping && (
              <div className="fade-in" style={{ display: "flex", alignItems: "flex-start", gap: "10px" }}>
                <div style={{ width: 32, height: 32, borderRadius: "10px", background: "rgba(255,255,255,0.06)", border: "1px solid var(--glass-border)", display: "flex", alignItems: "center", justifyContent: "center" }}>🤖</div>
                <div style={{ display: "flex", flexDirection: "column", gap: "6px" }}>
                  {/* Thinking animation */}
                  <div style={{ display: "flex", alignItems: "center", gap: "8px", background: "rgba(123,94,167,0.08)", border: "1px solid rgba(123,94,167,0.2)", borderRadius: "10px", padding: "8px 14px" }}>
                    <span style={{ fontSize: "14px", animation: "typingPulse 1s ease-in-out infinite" }}>🧠</span>
                    <span style={{ fontSize: "13px", color: "rgba(180,150,230,0.9)", fontStyle: "italic" }}>{thinkingPhrase || "Thinking..."}</span>
                    <div style={{ display: "flex", gap: "3px", marginLeft: "4px" }}>
                      {[0,1,2].map(i => (
                        <div key={i} style={{ width: 4, height: 4, borderRadius: "50%", background: "rgba(123,94,167,0.7)", animation: "typingPulse 0.8s ease-in-out infinite", animationDelay: `${i * 0.2}s` }} />
                      ))}
                    </div>
                  </div>
                </div>
              </div>
            )}
            <div ref={messagesEndRef} />
          </div>

          {/* 🎤 Listening bar */}
          {isListening && (
            <div style={{ margin: "0 16px 8px", padding: "10px 16px", background: "rgba(0,212,255,0.08)", border: "1px solid rgba(0,212,255,0.25)", borderRadius: "10px", display: "flex", alignItems: "center", gap: "10px" }}>
              <div style={{ display: "flex", gap: "3px", alignItems: "center" }}>
                {[1,2,3,4,5].map(i => <div key={i} style={{ width: 3, borderRadius: "3px", background: "var(--accent)", height: `${8 + i * 3}px`, animation: `typingPulse ${0.5 + i * 0.1}s ease-in-out infinite`, animationDelay: `${i * 0.1}s` }} />)}
              </div>
              <span style={{ fontSize: "13px", color: "var(--accent)", flex: 1 }}>🎤 Listening... <span style={{ color: "var(--text-secondary)" }}>{transcript || "speak now"}</span></span>
              <button onClick={stopListening} style={{ background: "rgba(255,77,109,0.1)", border: "1px solid rgba(255,77,109,0.2)", borderRadius: "6px", color: "var(--danger)", padding: "4px 10px", fontSize: "12px", cursor: "pointer" }}>Cancel</button>
            </div>
          )}

          {/* 🔊 Speaking bar */}
          {isSpeaking && (
            <div style={{ margin: "0 16px 8px", padding: "10px 16px", background: "rgba(0,229,160,0.06)", border: "1px solid rgba(0,229,160,0.2)", borderRadius: "10px", display: "flex", alignItems: "center", gap: "10px" }}>
              <span style={{ fontSize: "13px", color: "var(--success)", flex: 1 }}>🔊 Speaking response...</span>
              <button onClick={stopSpeaking} style={{ background: "rgba(255,77,109,0.1)", border: "1px solid rgba(255,77,109,0.2)", borderRadius: "6px", color: "var(--danger)", padding: "4px 10px", fontSize: "12px", cursor: "pointer" }}>Stop</button>
            </div>
          )}

          {/* 📎 Attachment preview bar */}
          {(attachedFile || isReadingFile) && (
            <div id="attach-preview" style={{ margin: "0 16px 8px", padding: "10px 16px", background: "rgba(123,94,167,0.08)", border: "1px solid rgba(123,94,167,0.25)", borderRadius: "10px", display: "flex", alignItems: "center", gap: "12px" }}>
              {isReadingFile ? (
                <>
                  <div style={{ display: "flex", gap: "4px", alignItems: "center" }}>
                    <div className="typing-dot" style={{ background: "var(--accent-2)" }} />
                    <div className="typing-dot" style={{ background: "var(--accent-2)" }} />
                    <div className="typing-dot" style={{ background: "var(--accent-2)" }} />
                  </div>
                  <span style={{ fontSize: "13px", color: "var(--text-secondary)" }}>Reading file...</span>
                </>
              ) : (
                <>
                  <span style={{ fontSize: "22px" }}>{getFileIcon(attachedFile.name)}</span>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ fontSize: "13px", color: "var(--text-primary)", fontWeight: 500, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{attachedFile.name}</div>
                    <div style={{ fontSize: "11px", color: "var(--text-muted)", marginTop: "2px" }}>{attachedFile.size} · Ready to analyze</div>
                  </div>
                  <div style={{ display: "flex", alignItems: "center", gap: "6px" }}>
                    <div style={{ width: 6, height: 6, borderRadius: "50%", background: "var(--success)", boxShadow: "0 0 6px var(--success)" }} />
                    <span style={{ fontSize: "11px", color: "var(--success)" }}>Attached</span>
                  </div>
                  <button onClick={removeAttachment} style={{ background: "rgba(255,77,109,0.1)", border: "1px solid rgba(255,77,109,0.2)", borderRadius: "6px", color: "var(--danger)", padding: "4px 10px", fontSize: "12px", cursor: "pointer", flexShrink: 0 }}>Remove</button>
                </>
              )}
            </div>
          )}

          <input ref={fileInputRef} type="file" accept={ACCEPTED_TYPES} onChange={handleFileAttach} style={{ display: "none" }} />

          {/* Input box */}
          <div className="glass" style={{ margin: "0 16px 16px", borderRadius: "14px", overflow: "hidden", flexShrink: 0 }}>
            <div style={{ display: "flex", alignItems: "flex-end", gap: "10px", padding: "12px 16px" }}>

              {/* 📎 Attach */}
              <button onClick={() => fileInputRef.current?.click()} disabled={isTyping || isReadingFile} title="Attach a document" style={{ width: 42, height: 42, borderRadius: "10px", cursor: "pointer", background: attachedFile ? "linear-gradient(135deg, rgba(123,94,167,0.4), rgba(123,94,167,0.2))" : "rgba(255,255,255,0.06)", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0, transition: "all 0.25s", fontSize: "18px", border: attachedFile ? "1px solid rgba(123,94,167,0.5)" : "1px solid transparent", boxShadow: attachedFile ? "0 0 14px rgba(123,94,167,0.3)" : "none" }}
                onMouseEnter={(e) => { if (!attachedFile) e.currentTarget.style.background = "rgba(255,255,255,0.1)"; }}
                onMouseLeave={(e) => { if (!attachedFile) e.currentTarget.style.background = "rgba(255,255,255,0.06)"; }}>
                📎
              </button>

              {/* Text input */}
              <textarea ref={inputRef} value={input} onChange={(e) => setInput(e.target.value)} onKeyDown={handleKey}
                placeholder={isListening ? "🎤 Listening..." : attachedFile ? `Ask anything about "${attachedFile.name}"...` : "Ask anything... I'll think before I answer 🧠"}
                rows={1} style={{ flex: 1, background: "none", border: "none", outline: "none", resize: "none", color: "var(--text-primary)", fontFamily: "DM Sans, sans-serif", fontSize: "15px", lineHeight: 1.6, maxHeight: "120px", overflowY: "auto", padding: "4px 0" }}
                onInput={(e) => { e.target.style.height = "auto"; e.target.style.height = Math.min(e.target.scrollHeight, 120) + "px"; }}
              />

              {/* 🎤 Mic */}
              {voiceSupported && (
                <button id="mic-btn" onClick={isListening ? stopListening : startListening} disabled={isTyping} style={{ width: 42, height: 42, borderRadius: "10px", border: "none", cursor: "pointer", background: isListening ? "linear-gradient(135deg, #ff4d6d, #ff6b6b)" : "rgba(255,255,255,0.06)", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0, transition: "all 0.25s", fontSize: "18px", boxShadow: isListening ? "0 0 20px rgba(255,77,109,0.4)" : "none" }}>
                  {isListening ? "⏹" : "🎤"}
                </button>
              )}

              {/* ↑ Send */}
              <button id="send-btn" onClick={sendMessage} disabled={!input.trim() || isTyping} style={{ width: 42, height: 42, borderRadius: "10px", border: "none", cursor: "pointer", background: input.trim() && !isTyping ? "linear-gradient(135deg, var(--accent), var(--accent-2))" : "rgba(255,255,255,0.06)", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0, transition: "all 0.25s", fontSize: "18px" }}>
                {isTyping ? "⏳" : "↑"}
              </button>
            </div>

            <div style={{ padding: "0 16px 10px", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
              <span style={{ fontSize: "11px", color: "var(--text-muted)" }}>
                Model: <span style={{ color: "var(--accent)" }}>{model}</span>
                <span style={{ marginLeft: "8px", color: "rgba(123,94,167,0.7)" }}>· 🧠 Reasoning Mode ON</span>
                {attachedFile && <span style={{ marginLeft: "8px", color: "rgba(123,94,167,0.8)" }}>· 📎 {attachedFile.name}</span>}
              </span>
              <span style={{ fontSize: "11px", color: "var(--text-muted)" }}>{input.length} chars</span>
            </div>
          </div>
        </div>
      </div>

      {/* Footer */}
      <div style={{ textAlign: "center", padding: "8px", color: "var(--text-muted)", fontSize: "11px", borderTop: "1px solid var(--glass-border)", flexShrink: 0, position: "relative", zIndex: 1 }}>
        Created by <span style={{ color: "var(--accent)", fontWeight: 600 }}>@techwithburhan</span> · Offline AI powered by Ollama · 🧠 Reasoning Mode
      </div>
    </div>
  );
}