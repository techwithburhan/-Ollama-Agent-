import React, { useState, useEffect, useRef } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import { gsap } from "gsap";

export default function Signup() {
  const [username, setUsername] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirm, setConfirm] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const { signup } = useAuth();
  const navigate = useNavigate();

  const cardRef = useRef(null);
  const logoRef = useRef(null);
  const fieldsRef = useRef(null);

  useEffect(() => {
    const tl = gsap.timeline();
    tl.fromTo(logoRef.current, { opacity: 0, y: -30 }, { opacity: 1, y: 0, duration: 0.7, ease: "power3.out" })
      .fromTo(cardRef.current, { opacity: 0, y: 40 }, { opacity: 1, y: 0, duration: 0.6, ease: "power3.out" }, "-=0.3")
      .fromTo(fieldsRef.current.children, { opacity: 0, x: -20 }, { opacity: 1, x: 0, stagger: 0.08, duration: 0.4 }, "-=0.2");
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    if (password !== confirm) {
      setError("Passwords do not match");
      gsap.to(cardRef.current, { x: [-8, 8, -6, 6, 0], duration: 0.4 });
      return;
    }
    if (password.length < 6) {
      setError("Password must be at least 6 characters");
      return;
    }
    setLoading(true);
    try {
      await signup(username, email, password);
      navigate("/chat");
    } catch (err) {
      setError(err.response?.data?.message || "Signup failed. Please try again.");
      gsap.to(cardRef.current, { x: [-8, 8, -6, 6, 0], duration: 0.4 });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ minHeight: "100vh", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", position: "relative", padding: "24px" }}>
      <div className="bg-grid" />
      <div className="orb orb-1" />
      <div className="orb orb-2" />
      <div className="orb orb-3" />

      <div ref={logoRef} style={{ textAlign: "center", marginBottom: "32px", position: "relative", zIndex: 1 }}>
        <div style={{
          width: 64, height: 64, borderRadius: "20px", margin: "0 auto 16px",
          background: "linear-gradient(135deg, rgba(0,212,255,0.2), rgba(123,94,167,0.2))",
          border: "1px solid rgba(0,212,255,0.3)",
          display: "flex", alignItems: "center", justifyContent: "center",
          fontSize: "28px", backdropFilter: "blur(10px)"
        }}>🤖</div>
        <h1 style={{ fontFamily: "Syne, sans-serif", fontSize: "26px", fontWeight: 800, letterSpacing: "-0.5px" }}>
          Ollama <span style={{ color: "var(--accent)" }}>Agent</span>
        </h1>
        <p style={{ color: "var(--text-secondary)", fontSize: "14px", marginTop: "4px" }}>Create your free account</p>
      </div>

      <div ref={cardRef} className="glass" style={{ width: "100%", maxWidth: 420, padding: "36px", position: "relative", zIndex: 1 }}>
        <div style={{ position: "absolute", top: 0, left: "20%", right: "20%", height: "1px", background: "linear-gradient(90deg, transparent, rgba(123,94,167,0.8), transparent)" }} />

        <h2 style={{ fontFamily: "Syne, sans-serif", fontSize: "22px", fontWeight: 700, marginBottom: "6px" }}>Get started</h2>
        <p style={{ color: "var(--text-secondary)", fontSize: "14px", marginBottom: "28px" }}>Join and start chatting with your local AI</p>

        <form onSubmit={handleSubmit}>
          <div ref={fieldsRef} style={{ display: "flex", flexDirection: "column", gap: "16px" }}>
            <div>
              <label style={{ display: "block", fontSize: "13px", color: "var(--text-secondary)", marginBottom: "8px", fontWeight: 500 }}>Username</label>
              <input
                type="text"
                className="input-field"
                placeholder="burhan123"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                required
                minLength={3}
              />
            </div>

            <div>
              <label style={{ display: "block", fontSize: "13px", color: "var(--text-secondary)", marginBottom: "8px", fontWeight: 500 }}>Email address</label>
              <input
                type="email"
                className="input-field"
                placeholder="you@example.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>

            <div>
              <label style={{ display: "block", fontSize: "13px", color: "var(--text-secondary)", marginBottom: "8px", fontWeight: 500 }}>Password</label>
              <input
                type="password"
                className="input-field"
                placeholder="Min. 6 characters"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>

            <div>
              <label style={{ display: "block", fontSize: "13px", color: "var(--text-secondary)", marginBottom: "8px", fontWeight: 500 }}>Confirm Password</label>
              <input
                type="password"
                className="input-field"
                placeholder="Repeat your password"
                value={confirm}
                onChange={(e) => setConfirm(e.target.value)}
                required
              />
            </div>

            {error && <div className="error-msg">{error}</div>}

            <button type="submit" className="btn-primary" disabled={loading}>
              {loading ? "Creating account..." : "Create account →"}
            </button>

            <p style={{ textAlign: "center", color: "var(--text-secondary)", fontSize: "14px" }}>
              Already have an account?{" "}
              <Link to="/login" style={{ color: "var(--accent)", textDecoration: "none", fontWeight: 500 }}>
                Sign in
              </Link>
            </p>
          </div>
        </form>
      </div>

      <footer style={{ position: "fixed", bottom: "24px", color: "var(--text-muted)", fontSize: "12px", zIndex: 1 }}>
        Created by{" "}
        <span style={{ color: "var(--accent)", fontWeight: 600 }}>@techwithburhan</span>
      </footer>
    </div>
  );
}
