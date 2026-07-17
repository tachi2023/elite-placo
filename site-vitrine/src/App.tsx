import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Home from './pages/Home';
import ClientDashboard from './pages/ClientDashboard';

function App() {
  return (
    <BrowserRouter>
      <div className="min-h-screen bg-anthracite text-white font-sans">
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/suivi/:code" element={<ClientDashboard />} />
        </Routes>
      </div>
    </BrowserRouter>
  );
}

export default App;
