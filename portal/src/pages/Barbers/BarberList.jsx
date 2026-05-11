import { useState, useEffect } from 'react';
import axios from 'axios';
import { Plus, Search, Check, X, Edit, Trash2, ShieldAlert, ShieldCheck, Eye } from 'lucide-react';
import { Link } from 'react-router-dom';
import ConfirmationModal from '../../components/ConfirmationModal';

const BarberList = () => {
  const [barbers, setBarbers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  
  // Modal State
  const [modalConfig, setModalConfig] = useState({
    isOpen: false,
    title: '',
    message: '',
    onConfirm: () => {},
    type: 'danger',
    confirmText: 'Confirm'
  });

  useEffect(() => {
    fetchBarbers();
  }, []);

  const fetchBarbers = async () => {
    try {
      const { data } = await axios.get('http://localhost:5000/api/barbers', {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      });
      setBarbers(data);
    } catch (error) {
      console.error('Failed to fetch barbers', error);
    } finally {
      setLoading(false);
    }
  };

  const openStatusModal = (barber, isApproved) => {
    setModalConfig({
      isOpen: true,
      title: isApproved ? 'Approve Barber' : 'Revoke Approval',
      message: `Are you sure you want to ${isApproved ? 'approve' : 'revoke the approval for'} ${barber.name}? ${isApproved ? 'They will be able to log in to the mobile app.' : 'They will lose access to the mobile app.'}`,
      type: isApproved ? 'info' : 'warning',
      confirmText: isApproved ? 'Approve Now' : 'Revoke Access',
      onConfirm: () => handleApprove(barber._id, isApproved)
    });
  };

  const openDeleteModal = (barber) => {
    setModalConfig({
      isOpen: true,
      title: 'Delete Barber Account',
      message: `Are you sure you want to delete ${barber.name}'s account? This will permanently remove all their data from the system. This action cannot be undone.`,
      type: 'danger',
      confirmText: 'Delete Permanently',
      onConfirm: () => handleDelete(barber._id)
    });
  };

  const handleApprove = async (id, isApproved) => {
    try {
      await axios.put(`http://localhost:5000/api/barbers/${id}/approve`, { isApproved }, {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      });
      fetchBarbers();
    } catch (error) {
      console.error('Failed to update status', error);
    }
  };

  const handleDelete = async (id) => {
    try {
      await axios.delete(`http://localhost:5000/api/barbers/${id}`, {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      });
      fetchBarbers();
    } catch (error) {
      console.error('Failed to delete barber', error);
    }
  };

  const filteredBarbers = barbers.filter(b => 
    b.name.toLowerCase().includes(search.toLowerCase()) || 
    b.shopName.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-6 text-white">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <h1 className="text-2xl font-semibold">Barber Management</h1>
        <Link
          to="/barbers/create"
          className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-purple-600 hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500 transition-colors"
        >
          <Plus className="-ml-1 mr-2 h-5 w-5" />
          Add New Barber
        </Link>
      </div>

      <div className="bg-gray-900 border border-gray-800 rounded-xl overflow-hidden shadow-sm">
        <div className="p-4 border-b border-gray-800 flex items-center">
          <div className="relative w-full max-w-md">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <Search className="h-5 w-5 text-gray-500" />
            </div>
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="block w-full pl-10 pr-3 py-2 border border-gray-700 rounded-md leading-5 bg-gray-800 text-gray-300 placeholder-gray-500 focus:outline-none focus:ring-1 focus:ring-purple-500 focus:border-purple-500 sm:text-sm transition-colors"
              placeholder="Search barbers by name or shop..."
            />
          </div>
        </div>
        
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-800">
            <thead className="bg-gray-800/50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Barber Info</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Contact</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Approval Status</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Location</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody className="bg-gray-900 divide-y divide-gray-800">
              {loading ? (
                <tr>
                  <td colSpan="5" className="px-6 py-10 text-center text-sm text-gray-400">Loading barbers...</td>
                </tr>
              ) : filteredBarbers.length === 0 ? (
                <tr>
                  <td colSpan="5" className="px-6 py-10 text-center text-sm text-gray-400">No barbers found.</td>
                </tr>
              ) : (
                filteredBarbers.map((barber) => (
                  <tr key={barber._id} className="hover:bg-gray-800/50 transition-colors">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <div className="flex-shrink-0 h-10 w-10 bg-gray-700 rounded-full overflow-hidden flex items-center justify-center">
                          {barber.profilePhoto ? (
                            <img src={`http://localhost:5000${barber.profilePhoto}`} alt="" className="h-10 w-10 object-cover" />
                          ) : (
                            <span className="text-gray-400 text-sm font-bold">{barber.name.charAt(0)}</span>
                          )}
                        </div>
                        <div className="ml-4">
                          <div className="text-sm font-medium text-white">{barber.name}</div>
                          <div className="text-sm text-gray-400">{barber.shopName}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-white">{barber.email}</div>
                      <div className="text-sm text-gray-400">{barber.mobile}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      {barber.isApproved ? (
                        <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-500/10 text-green-500">
                          <ShieldCheck className="w-3 h-3 mr-1" />
                          Approved
                        </span>
                      ) : (
                        <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-yellow-500/10 text-yellow-500">
                          <ShieldAlert className="w-3 h-3 mr-1" />
                          Pending
                        </span>
                      )}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-white">{barber.location?.city}</div>
                      <div className="text-sm text-gray-400 truncate max-w-[150px]">{barber.location?.address}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-3">
                      {!barber.isApproved ? (
                        <button onClick={() => openStatusModal(barber, true)} className="text-green-500 hover:text-green-400 transition-colors" title="Approve">
                          <Check className="w-5 h-5" />
                        </button>
                      ) : (
                        <button onClick={() => openStatusModal(barber, false)} className="text-yellow-500 hover:text-yellow-400 transition-colors" title="Revoke Approval">
                          <X className="w-5 h-5" />
                        </button>
                      )}
                      <Link to={`/barbers/edit/${barber._id}`} className="text-blue-500 hover:text-blue-400 inline-block transition-colors" title="Edit">
                        <Edit className="w-5 h-5" />
                      </Link>
                      <Link to={`/transactions?barberId=${barber._id}`} className="text-purple-500 hover:text-purple-400 inline-block transition-colors" title="View Transaction History">
                        <Eye className="w-5 h-5" />
                      </Link>
                      <button onClick={() => openDeleteModal(barber)} className="text-red-500 hover:text-red-400 transition-colors" title="Delete">
                        <Trash2 className="w-5 h-5" />
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Reusable Confirmation Modal */}
      <ConfirmationModal 
        isOpen={modalConfig.isOpen}
        onClose={() => setModalConfig({ ...modalConfig, isOpen: false })}
        onConfirm={modalConfig.onConfirm}
        title={modalConfig.title}
        message={modalConfig.message}
        type={modalConfig.type}
        confirmText={modalConfig.confirmText}
      />
    </div>
  );
};

export default BarberList;
