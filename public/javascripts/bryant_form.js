// Wait for page to load
window.onload = function() {

    var currentPageNumber = 1,
        page1 = document.getElementById("page1"),
        page2 = document.getElementById("page2"),
        page3 = document.getElementById("page3"),
        page4 = document.getElementById("page4"),
        submitBtn = document.getElementById("form-submit"),
        nextBtn = document.getElementById("nextBtn"),
        prevBtn = document.getElementById("prevBtn");

    // Hide pages 2-4, submit & prev button
    page2.style.display = "none";
    page3.style.display = "none";
    page4.style.display = "none";
    submitBtn.style.display = "none";
    prevBtn.style.display = "none";

    // Bind skip-question events
    var q14_skip_item = document.getElementById("14");
    if (q14_skip_item) {
        q14_skip_item.addEventListener("change", skipItemQ14);
    }

    function skipItemQ14(event) {
        if (q14_skip_item.checked) {
            document.getElementById("q15").style.display="none";
            document.getElementById("q16").style.display="none";
            document.getElementById("q17").style.display="none";
            document.getElementById("q18").style.display="none";
            document.getElementById("q19").style.display="none";
            document.getElementById("q20").style.display="none";
            document.getElementById("q21").style.display="none";
            document.getElementById("q22").style.display="none";
            document.getElementById("q23").style.display="none";
            document.getElementById("q24").style.display="none";
        } else {
            document.getElementById("q15").style.display="block";
            document.getElementById("q16").style.display="block";
            document.getElementById("q17").style.display="block";
            document.getElementById("q18").style.display="block";
            document.getElementById("q19").style.display="block";
            document.getElementById("q20").style.display="block";
            document.getElementById("q21").style.display="block";
            document.getElementById("q22").style.display="block";
            document.getElementById("q23").style.display="block";
            document.getElementById("q24").style.display="block";
        }
    }

    var q16_skip_item = document.getElementById("16_always");
    if (q16_skip_item) {
        q16_skip_item.addEventListener("change", skipItemQ16);
    }

    var q16_skip_item = document.getElementById("16_often");
    if (q16_skip_item) {
        q16_skip_item.addEventListener("change", skipItemQ16);
    }

    var q16_skip_item = document.getElementById("16_sometimes");
    if (q16_skip_item) {
        q16_skip_item.addEventListener("change", skipItemQ16);
    }

    var q16_skip_item = document.getElementById("16_not_often");
    if (q16_skip_item) {
        q16_skip_item.addEventListener("change", skipItemQ16);
    }

    var q16_skip_item = document.getElementById("16_never");
    if (q16_skip_item) {
        q16_skip_item.addEventListener("change", skipItemQ16);
    }

    function skipItemQ16(event) {
        if (q16_skip_item.checked) {
            document.getElementById("q17").style.display="none";
        } else {
            document.getElementById("q17").style.display="block";
        }
    }

    var q19_skip_item = document.getElementById("19_always");
    if (q19_skip_item) {
        q19_skip_item.addEventListener("change", skipItemQ19);
    }

    var q19_skip_item = document.getElementById("19_often");
    if (q19_skip_item) {
        q19_skip_item.addEventListener("change", skipItemQ19);
    }

    var q19_skip_item = document.getElementById("19_sometimes");
    if (q19_skip_item) {
        q19_skip_item.addEventListener("change", skipItemQ19);
    }

    var q19_skip_item = document.getElementById("19_not_often");
    if (q19_skip_item) {
        q19_skip_item.addEventListener("change", skipItemQ19);
    }

    var q19_skip_item = document.getElementById("19_never");
    if (q19_skip_item) {
        q19_skip_item.addEventListener("change", skipItemQ19);
    }

    function skipItemQ19(event) {
        if (q19_skip_item.checked) {
            document.getElementById("q20").style.display="none";
        } else {
            document.getElementById("q20").style.display="block";
        }
    }

    var q22_skip_item = document.getElementById("22_always");
    if (q22_skip_item) {
        q22_skip_item.addEventListener("change", skipItemQ22);
    }

    var q22_skip_item = document.getElementById("22_often");
    if (q22_skip_item) {
        q22_skip_item.addEventListener("change", skipItemQ22);
    }

    var q22_skip_item = document.getElementById("22_sometimes");
    if (q22_skip_item) {
        q22_skip_item.addEventListener("change", skipItemQ22);
    }

    var q22_skip_item = document.getElementById("22_not_often");
    if (q22_skip_item) {
        q22_skip_item.addEventListener("change", skipItemQ22);
    }

    var q22_skip_item = document.getElementById("22_never");
    if (q22_skip_item) {
        q22_skip_item.addEventListener("change", skipItemQ22);
    }

    function skipItemQ22(event) {
        if (q22_skip_item.checked) {
            document.getElementById("q23").style.display="none";
        } else {
            document.getElementById("q23").style.display="block";
        }
    }

    var q26_skip_item = document.getElementById("26");
    if (q26_skip_item) {
        q26_skip_item.addEventListener("change", skipItemQ26);
    }

    function skipItemQ26(event) {
        if (q26_skip_item.checked) {
            document.getElementById("q27").style.display="none";
        } else {
            document.getElementById("q27").style.display="block";
        }
    }

    var q30_skip_item = document.getElementById("30");
    if (q30_skip_item) {
        q30_skip_item.addEventListener("change", skipItemQ30);
    }

    function skipItemQ30(event) {
        if (q30_skip_item.checked) {
            document.getElementById("q31").style.display="none";
        } else {
            document.getElementById("q31").style.display="block";
        }
    }

    var q34_skip_item = document.getElementById("34");
    if (q34_skip_item) {
        q34_skip_item.addEventListener("change", skipItemQ34);
    }

    function skipItemQ34(event) {
        if (q34_skip_item.checked) {
            document.getElementById("q35").style.display="none";
        } else {
            document.getElementById("q35").style.display="block";
        }
    }

    var q38_skip_item = document.getElementById("38");
    if (q38_skip_item) {
        q38_skip_item.addEventListener("change", skipItemQ38);
    }

    function skipItemQ38(event) {
        if (q38_skip_item.checked) {
            document.getElementById("q39").style.display="none";
        } else {
            document.getElementById("q39").style.display="block";
        }
    }

    nextBtn.addEventListener("click", nextPage);
    prevBtn.addEventListener("click", prevPage);

    function nextPage(event) {
        // Hide previous page
        var currentPage = "page" + currentPageNumber.toString();
        document.getElementById(currentPage).style.display = "none";

        // Increment the page number
        currentPageNumber++;

        // Hide and display buttons accordingly
        if (currentPageNumber === 1) {
            prevBtn.style.display = "none";
            nextBtn.style.display = "block";
            submitBtn.style.display = "none";
        } else if (currentPageNumber === 4 ) {
            prevBtn.style.display = "block";
            nextBtn.style.display = "none";
            submitBtn.style.display = "block";
        } else {
            prevBtn.style.display = "block";
            nextBtn.style.display = "block";
            submitBtn.style.display = "none";
        }

        // Stitch together the page id we want next
        currentPage = "page" + currentPageNumber.toString();
        // Make it visible
        document.getElementById(currentPage).style.display = "block";
        // Update page header
        updatePageHeader();
        // Scroll to top
        window.scrollTo(0, 0);
    }

    function prevPage(event) {
        // Hide previous page
        var currentPage = "page" + currentPageNumber.toString();
        document.getElementById(currentPage).style.display = "none";

        // Increment the page number
        currentPageNumber--;

        // Hide and display buttons accordingly
        if (currentPageNumber === 1) {
            prevBtn.style.display = "none";
            nextBtn.style.display = "block";
            submitBtn.style.display = "none";
        } else if (currentPageNumber === 4 ) {
            prevBtn.style.display = "block";
            nextBtn.style.display = "none";
            submitBtn.style.display = "block";
        } else {
            prevBtn.style.display = "block";
            nextBtn.style.display = "block";
            submitBtn.style.display = "none";
        }

        // Stitch together the page id we want next
        currentPage = "page" + currentPageNumber.toString();
        // Make it visible
        document.getElementById(currentPage).style.display = "block";
        // Update page header
        updatePageHeader();
        // Scroll to top
        window.scrollTo(0, 0);
    }

    function updatePageHeader() {
        if (currentPageNumber === 1) {
            document.getElementsByTagName("h1")[1].innerHTML = "Respondent and Background Information";
        } else if (currentPageNumber === 2) {
            document.getElementsByTagName("h1")[1].innerHTML = "Entering Data into SRDR";
        } else if (currentPageNumber === 3) {
            document.getElementsByTagName("h1")[1].innerHTML = "Training Resources";
        } else if (currentPageNumber === 4) {
            document.getElementsByTagName("h1")[1].innerHTML = "General";
        }
    }

}// end of window.onload
