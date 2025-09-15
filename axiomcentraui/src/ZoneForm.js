import React from 'react';
import './Form.css';

function ZoneForm({ mode, data, onSave, onCancel }) {
  return (
    
    <div className="ZoneForm">
      <h2>{mode === 'edit' ? 'Edit Zone' : 'Add Zone'}</h2>

      {/* Placeholder for form fields */}
      <div className="FormBody">
        <p style={{ color: '#aaa' }}>
          {mode === 'edit' ? `Editing ${data?.name}` : 'Creating new zone'}
        </p>
        {/* You’ll add actual inputs later */}
      </div>

      <div className="FormActions">
        <button className="FormButton" onClick={() => onSave({ dummy: true })}>
          Save
        </button>
        <button className="FormButton Cancel" onClick={onCancel}>
          Cancel
        </button>
      </div>
    </div>
  );
}

export default ZoneForm;
