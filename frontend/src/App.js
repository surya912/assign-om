import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000';

function App() {
  const [ideas, setIdeas] = useState([]);
  const [newIdea, setNewIdea] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchIdeas();
  }, []);

  const fetchIdeas = async () => {
    try {
      setLoading(true);
      const response = await axios.get(`${API_URL}/api/ideas`);
      setIdeas(response.data);
      setError(null);
    } catch (err) {
      setError('Failed to fetch ideas. Please try again.');
      console.error('Error fetching ideas:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!newIdea.trim()) {
      setError('Please enter an idea');
      return;
    }

    try {
      setLoading(true);
      const response = await axios.post(`${API_URL}/api/ideas`, {
        content: newIdea.trim()
      });
      setIdeas([response.data, ...ideas]);
      setNewIdea('');
      setError(null);
    } catch (err) {
      setError('Failed to submit idea. Please try again.');
      console.error('Error submitting idea:', err);
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleString();
  };

  return (
    <div className="App">
      <div className="container">
        <header className="header">
          <h1>💡 Idea Board</h1>
          <p>Share your ideas and see what others are thinking!</p>
        </header>

        <form onSubmit={handleSubmit} className="idea-form">
          <div className="form-group">
            <textarea
              value={newIdea}
              onChange={(e) => setNewIdea(e.target.value)}
              placeholder="What's your idea?"
              rows="3"
              disabled={loading}
            />
          </div>
          <button type="submit" disabled={loading || !newIdea.trim()}>
            {loading ? 'Submitting...' : 'Submit Idea'}
          </button>
        </form>

        {error && <div className="error-message">{error}</div>}

        <div className="ideas-section">
          <h2>All Ideas ({ideas.length})</h2>
          {loading && ideas.length === 0 ? (
            <div className="loading">Loading ideas...</div>
          ) : ideas.length === 0 ? (
            <div className="empty-state">No ideas yet. Be the first to share!</div>
          ) : (
            <div className="ideas-list">
              {ideas.map((idea) => (
                <div key={idea.id} className="idea-card">
                  <p className="idea-content">{idea.content}</p>
                  <span className="idea-date">{formatDate(idea.created_at)}</span>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default App;

