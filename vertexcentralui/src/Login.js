import React from 'react';
import { useNavigate } from 'react-router-dom';
import './Login.css';

function Login() {

  const navigate = useNavigate();

  const handleSubmit = (e) => {
    e.preventDefault();
    // TODO: Add actual auth logic here
    navigate('/main-window'); // Navigate to System Admin dashboard
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

export default Login;