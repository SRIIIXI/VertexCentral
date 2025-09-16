import React from 'react';
import './SlidePanel.css';

function SlidePanel({ children, onClose }) {
  return (
    <div className="SlidePanel">
      <div className="SlidePanelHeader">
        <button className="CloseButton" onClick={onClose}>✖</button>
      </div>
      <div className="SlidePanelBody">
        {children}
      </div>
    </div>
  );
}

export default SlidePanel;
