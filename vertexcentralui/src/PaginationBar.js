import React from 'react';
import './Listing.css';

function PaginationBar({ currentPage, totalItems, itemsPerPage, onPageChange }) {
  const totalPages = Math.ceil(totalItems / itemsPerPage);

  return (
    <div className="PaginationBar">
      <button
        className="PageButton"
        disabled={currentPage === 1}
        onClick={() => onPageChange(currentPage - 1)}
      >
        ◀ Prev
      </button>

      <span className="PageInfo">
        Page {currentPage} of {totalPages}
      </span>

      <button
        className="PageButton"
        disabled={currentPage === totalPages}
        onClick={() => onPageChange(currentPage + 1)}
      >
        Next ▶
      </button>
    </div>
  );
}

export default PaginationBar;

