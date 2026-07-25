import { BrowserRouter, Routes, Route } from 'react-router-dom';
import ScrollToTop from './components/ScrollToTop';
import Home from './pages/Home';
import Services from './pages/Services';
import Realisations from './pages/Realisations';
import Devis from './pages/Devis';
import EspaceClient from './pages/EspaceClient';
import ClientDashboard from './pages/ClientDashboard';
import Contact from './pages/Contact';
import ChantiersPage from './pages/ChantiersPage';
import DashboardPage from './pages/DashboardPage';
import NewChantierPage from './pages/NewChantierPage';

function App() {
  return (
    <BrowserRouter>
      <ScrollToTop />
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/services" element={<Services />} />
        <Route path="/realisations" element={<Realisations />} />
        <Route path="/devis" element={<Devis />} />
        <Route path="/contact" element={<Contact />} />
        <Route path="/espace-client" element={<EspaceClient />} />
        <Route path="/chantiers" element={<ChantiersPage />} />
        <Route path="/chantiers/new" element={<NewChantierPage />} />
        <Route path="/dashboard" element={<DashboardPage />} />
        <Route path="/parametres" element={<div className="min-h-screen bg-[#050505] p-8 text-white">Paramètres à venir</div>} />
        <Route path="/parametres/materiaux" element={<div className="min-h-screen bg-[#050505] p-8 text-white">Prix matériaux à venir</div>} />
        <Route path="/suivi/:code" element={<ClientDashboard />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
