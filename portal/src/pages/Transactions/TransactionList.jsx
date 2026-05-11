import { useState, useEffect } from 'react';
import axios from 'axios';
import { Filter, X, ArrowLeft } from 'lucide-react';
import { useSearchParams, useNavigate } from 'react-router-dom';

const TransactionList = () => {
  const [transactions, setTransactions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchParams, setSearchParams] = useSearchParams();
  const navigate = useNavigate();
  const barberId = searchParams.get('barberId');

  const [filterType, setFilterType] = useState('all');

  useEffect(() => {
    fetchTransactions();
  }, [barberId]);

  const fetchTransactions = async () => {
    setLoading(true);
    try {
      let url = 'http://localhost:5000/api/transactions';
      if (barberId) {
        url += `?barberId=${barberId}`;
      }
      const { data } = await axios.get(url, {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      });
      setTransactions(data);
    } catch (error) {
      console.error('Failed to fetch transactions', error);
    } finally {
      setLoading(false);
    }
  };

  const clearFilter = () => {
    setSearchParams({});
  };

  const filteredData = transactions.filter(tx => filterType === 'all' || tx.paymentType === filterType);
  const filteredBarberName = barberId && transactions.length > 0 ? transactions[0].barber?.name : null;

  return (
    <div className="space-y-6 text-white">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <div className="flex items-center space-x-2">
            {barberId && (
              <button 
                onClick={() => navigate('/barbers')}
                className="p-1 hover:bg-gray-800 rounded-full transition-colors mr-2"
                title="Back to Barbers"
              >
                <ArrowLeft className="h-5 w-5" />
              </button>
            )}
            <h1 className="text-2xl font-semibold">
              {barberId ? `Sales History: ${filteredBarberName || 'Loading...'}` : 'Transactions & Sales'}
            </h1>
          </div>
          {barberId && (
            <p className="text-sm text-gray-400 mt-1 flex items-center">
              Showing records for specific barber 
              <button onClick={clearFilter} className="ml-2 text-purple-400 hover:text-purple-300 flex items-center">
                (Clear Filter <X className="h-3 w-3 ml-0.5" />)
              </button>
            </p>
          )}
        </div>
        <div className="flex items-center space-x-2 bg-gray-900 border border-gray-800 p-3 rounded-xl">
          <span className="text-sm text-gray-400">Total Volume:</span>
          <span className="text-xl font-bold text-green-400">
            ₹{filteredData.reduce((acc, tx) => acc + (tx.amount || 0), 0).toLocaleString()}
          </span>
        </div>
      </div>

      <div className="bg-gray-900 border border-gray-800 rounded-xl overflow-hidden shadow-sm">
        <div className="p-4 border-b border-gray-800 flex flex-wrap gap-4 items-center justify-between">
          <div className="flex items-center space-x-2">
            <Filter className="h-5 w-5 text-gray-500" />
            <select 
              className="bg-gray-800 border border-gray-700 text-white text-sm rounded-lg focus:ring-purple-500 focus:border-purple-500 block p-2.5 outline-none transition-all"
              value={filterType}
              onChange={(e) => setFilterType(e.target.value)}
            >
              <option value="all">All Payment Types</option>
              <option value="online">Online Payment</option>
              <option value="cash">Cash Payment</option>
            </select>
          </div>
          <div className="text-sm text-gray-400">
            Found {filteredData.length} records
          </div>
        </div>
        
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-800">
            <thead className="bg-gray-800/50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Date & ID</th>
                {!barberId && <th className="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Barber</th>}
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Customer</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Type</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Amount</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Status</th>
              </tr>
            </thead>
            <tbody className="bg-gray-900 divide-y divide-gray-800">
              {loading ? (
                <tr>
                  <td colSpan="6" className="px-6 py-10 text-center text-sm text-gray-400">Loading transactions...</td>
                </tr>
              ) : filteredData.length === 0 ? (
                <tr>
                  <td colSpan="6" className="px-6 py-10 text-center text-sm text-gray-400">No transactions found.</td>
                </tr>
              ) : (
                filteredData.map((tx) => (
                  <tr key={tx._id} className="hover:bg-gray-800/50 transition-colors">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-white">{new Date(tx.createdAt).toLocaleDateString()}</div>
                      <div className="text-xs text-gray-500 font-mono">#{tx._id.slice(-6).toUpperCase()}</div>
                    </td>
                    {!barberId && (
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-white font-medium">{tx.barber?.name || 'Unknown'}</div>
                        <div className="text-xs text-gray-500">{tx.barber?.shopName}</div>
                      </td>
                    )}
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-white">{tx.customer?.name || 'Guest'}</div>
                      <div className="text-xs text-gray-500">{tx.customer?.email}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`px-2.5 py-0.5 inline-flex text-xs leading-5 font-semibold rounded-full ${
                        tx.paymentType === 'online' ? 'bg-blue-500/10 text-blue-400' : 'bg-green-500/10 text-green-400'
                      }`}>
                        {tx.paymentType?.toUpperCase()}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-white font-bold">
                      ₹{tx.amount?.toLocaleString()}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`px-2.5 py-0.5 inline-flex text-xs leading-5 font-semibold rounded-full ${
                        tx.status === 'completed' ? 'bg-green-500/10 text-green-400' : 
                        tx.status === 'pending' ? 'bg-yellow-500/10 text-yellow-400' : 'bg-red-500/10 text-red-400'
                      }`}>
                        {tx.status?.toUpperCase()}
                      </span>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default TransactionList;
