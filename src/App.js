import { useState, useEffect } from 'react';
import ReactMarkdown from 'react-markdown';
import './App.css';

// API base URL from environment or default
const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000/api';

function App() {
  const [notes, setNotes] = useState([]);
  const [currentNote, setCurrentNote] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Fetch notes from API
  useEffect(() => {
    const fetchNotes = async () => {
      try {
        setLoading(true);
        const response = await fetch(`${API_URL}/notes`);
        if (!response.ok) {
          throw new Error(`API error: ${response.status}`);
        }
        const data = await response.json();
        setNotes(data);
        setError(null);
      } catch (err) {
        console.error('Error fetching notes:', err);
        setError('Failed to load notes. Please try again later.');
      } finally {
        setLoading(false);
      }
    };

    fetchNotes();
  }, []);

  // Add a new note
  const addNote = async () => {
    if (currentNote.trim() === '') return;
    
    try {
      const response = await fetch(`${API_URL}/notes`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ text: currentNote }),
      });

      if (!response.ok) {
        throw new Error(`API error: ${response.status}`);
      }

      const newNote = await response.json();
      setNotes([newNote, ...notes]);
      setCurrentNote('');
      setError(null);
    } catch (err) {
      console.error('Error adding note:', err);
      setError('Failed to add note. Please try again.');
    }
  };

  // Delete a note
  const deleteNote = async (id) => {
    try {
      const response = await fetch(`${API_URL}/notes/${id}`, {
        method: 'DELETE',
      });

      if (!response.ok) {
        throw new Error(`API error: ${response.status}`);
      }

      setNotes(notes.filter(note => note._id !== id));
      setError(null);
    } catch (err) {
      console.error('Error deleting note:', err);
      setError('Failed to delete note. Please try again.');
    }
  };

  const formatDate = (dateString) => {
    const options = { 
      year: 'numeric', 
      month: 'short', 
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    };
    return new Date(dateString).toLocaleDateString(undefined, options);
  };

  return (
    <div className="App">
      <div className="notes-container">
        <div className="app-header">
          <div className="logo-container">
            {/* Replace with your actual logo */}
            <span style={{ fontSize: '24px', fontWeight: 'bold', color: 'white' }}>N</span>
          </div>
          <h1>Notes App</h1>
        </div>
        
        {error && <div className="error-message">{error}</div>}
        
        <div className="input-container">
          <div className="formatting-help">
            Supports markdown: **bold**, *italic*, `code`, # headers, {'>'}quotes, links, etc.
          </div>
          <textarea 
            value={currentNote}
            onChange={(e) => setCurrentNote(e.target.value)}
            placeholder="Type your note here using markdown..."
          />
          <button onClick={addNote}>Add Note</button>
        </div>
        
        <div className="notes-list">
          {loading ? (
            <p className="loading-message">Loading notes...</p>
          ) : notes.length === 0 ? (
            <p className="empty-notes">No notes yet. Add one above!</p>
          ) : (
            notes.map(note => (
              <div key={note._id} className="note">
                <div className="note-header">
                  <span>{formatDate(note.timestamp || note.createdAt)}</span>
                </div>
                <div className="note-content">
                  <ReactMarkdown>{note.text}</ReactMarkdown>
                </div>
                <button 
                  className="delete-btn"
                  onClick={() => deleteNote(note._id)}
                >
                  Delete
                </button>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
}

export default App;
