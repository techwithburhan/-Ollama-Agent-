// import React, { createContext, useContext, useState, useEffect } from "react";
// import axios from "axios";

// const AuthContext = createContext();

// axios.defaults.baseURL = "http://localhost:5005";

// export const useAuth = () => useContext(AuthContext);

// export const AuthProvider = ({ children }) => {
//   const [user, setUser] = useState(null);
//   const [token, setToken] = useState(localStorage.getItem("token"));
//   const [loading, setLoading] = useState(true);

//   useEffect(() => {
//     if (token) {
//       axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
//       fetchUser();
//     } else {
//       setLoading(false);
//     }
//   }, [token]);

//   const fetchUser = async () => {
//     try {
//       const res = await axios.get("/api/auth/me");
//       setUser(res.data.user);
//     } catch {
//       logout();
//     } finally {
//       setLoading(false);
//     }
//   };

//   const login = async (email, password) => {
//     const res = await axios.post("/api/auth/login", { email, password });
//     const { token: newToken, user: newUser } = res.data;
//     localStorage.setItem("token", newToken);
//     axios.defaults.headers.common["Authorization"] = `Bearer ${newToken}`;
//     setToken(newToken);
//     setUser(newUser);
//     return res.data;
//   };

//   const signup = async (username, email, password) => {
//     const res = await axios.post("/api/auth/signup", { username, email, password });
//     const { token: newToken, user: newUser } = res.data;
//     localStorage.setItem("token", newToken);
//     axios.defaults.headers.common["Authorization"] = `Bearer ${newToken}`;
//     setToken(newToken);
//     setUser(newUser);
//     return res.data;
//   };

//   const logout = () => {
//     localStorage.removeItem("token");
//     delete axios.defaults.headers.common["Authorization"];
//     setToken(null);
//     setUser(null);
//   };

//   return (
//     <AuthContext.Provider value={{ user, token, loading, login, signup, logout }}>
//       {children}
//     </AuthContext.Provider>
//   );
// };

import React, { createContext, useContext, useState, useEffect } from "react";
import axios from "axios";

const AuthContext = createContext();

// ✅ Uses env var if set, otherwise empty string = relative URLs (nginx proxy handles it)
const BASE_URL = process.env.REACT_APP_API_URL || "";
axios.defaults.baseURL = BASE_URL;

export const useAuth = () => useContext(AuthContext);

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [token, setToken] = useState(localStorage.getItem("token"));
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (token) {
      axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
      fetchUser();
    } else {
      setLoading(false);
    }
  }, [token]);

  const fetchUser = async () => {
    try {
      const res = await axios.get("/api/auth/me");
      setUser(res.data.user);
    } catch {
      logout();
    } finally {
      setLoading(false);
    }
  };

  const login = async (email, password) => {
    const res = await axios.post("/api/auth/login", { email, password });
    const { token: newToken, user: newUser } = res.data;
    localStorage.setItem("token", newToken);
    axios.defaults.headers.common["Authorization"] = `Bearer ${newToken}`;
    setToken(newToken);
    setUser(newUser);
    return res.data;
  };

  const signup = async (username, email, password) => {
    const res = await axios.post("/api/auth/signup", { username, email, password });
    const { token: newToken, user: newUser } = res.data;
    localStorage.setItem("token", newToken);
    axios.defaults.headers.common["Authorization"] = `Bearer ${newToken}`;
    setToken(newToken);
    setUser(newUser);
    return res.data;
  };

  const logout = () => {
    localStorage.removeItem("token");
    delete axios.defaults.headers.common["Authorization"];
    setToken(null);
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, token, loading, login, signup, logout }}>
      {children}
    </AuthContext.Provider>
  );
};