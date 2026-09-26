import { BrowserRouter, Navigate, Routes, Route } from 'react-router-dom';
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
import ParametresPage from './pages/ParametresPage';
import MateriauxPage from './pages/MateriauxPage';
import AdminLoginPage from './pages/AdminLoginPage';
import SiteContentAdminPage from './pages/SiteContentAdminPage';

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
        <Route path="/admin" element={<DashboardPage />} />
        <Route path="/chantiers" element={<ChantiersPage />} />
        <Route path="/chantiers/new" element={<NewChantierPage />} />
        <Route path="/dashboard" element={<DashboardPage />} />
        <Route path="/parametres" element={<ParametresPage />} />
        <Route path="/parametres/materiaux" element={<MateriauxPage />} />
        <Route path="/suivi/:code" element={<ClientDashboard />} />
        <Route path="/admin/login" element={<AdminLoginPage />} />
        <Route path="/admin/site" element={<SiteContentAdminPage />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
