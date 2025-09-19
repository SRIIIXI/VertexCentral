import React from 'react';
import './Listing.css';

function PaginationBar({ currentPage, totalItems, itemsPerPage, onPageChange }) {
  const totalPages = Math.ceil(totalItems / itemsPerPage);

  console.log("PaginationBar props:", {currentPage, totalItems, itemsPerPage, totalPages});

  return (

  <div className="PaginationBar">
    <button
      className="PageButton"
      disabled={currentPage === 1}
      onClick={() => onPageChange(currentPage - 1)}
    >
      ◀ Prev
    </button>

    {[...Array(totalPages)].map((_, i) => {
      const page = i + 1;
      return (
        <button
          key={page}
          className={`PageButton ${page === currentPage ? 'ActivePage' : ''}`}
          onClick={() => onPageChange(page)}
        >
          {page}
        </button>
      );
    })}

    <button
      className="PageButton"
      disabled={currentPage === totalPages}
      onClick={() => onPageChange(currentPage + 1)}
    >
      Next ▶
    </button>
  </div>


    // <div className="PaginationBar">
    //   <button
    //     className="PageButton"
    //     disabled={currentPage === 1}
    //     onClick={() => onPageChange(currentPage - 1)}
    //   >
    //     ◀ Prev
    //   </button>

    //   <span className="PageInfo">
    //     Page {currentPage} of {totalPages}
    //   </span>

    //   <button
    //     className="PageButton"
    //     disabled={currentPage === totalPages}
    //     onClick={() => onPageChange(currentPage + 1)}
    //   >
    //     Next ▶
    //   </button>
    // </div>
  );
}

export default PaginationBar;

