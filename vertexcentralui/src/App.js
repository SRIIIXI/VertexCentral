
import React, { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import logo from './logo.svg';
import './App.css';

function App() 
{
  console.log("Running on port:", window.location.port);
  const navigate = useNavigate();

    const handleSubmit = (e) => {
    e.preventDefault();
    // TODO: Add actual auth logic here
    navigate('/service-initializer'); // Navigate to System Admin dashboard
  };
  
  return (

    <div className="Login">
      <h2>Login</h2>
      <form onSubmit={handleSubmit}>
        <input type="text" placeholder="Username" required />
        <input type="password" placeholder="Password" required />
        <button type="submit">Sign In</button>
      </form>

      <div className="forgot-password">
        <a href="/forgot-password">Forgot Password?</a>
      </div>
      
    </div>

  );
}

export default App;
