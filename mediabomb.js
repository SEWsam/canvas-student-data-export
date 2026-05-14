/**
 * mediabomb.js
 *
 * A MutationObserver intercepts every iframe / video / audio / object / embed
 * as it is inserted and immediately replaces it with a plain <a> link showing
 * the source URL. SingleFile then serializes a fully static DOM with no live
 * media streams, eliminating the hang entirely.
 */
(function () {
    "use strict";

    var MEDIA_TAGS = ["iframe", "video", "audio", "object", "embed"];

    function makeLink(el) {
        var src =
            el.src ||
            el.data ||
            el.getAttribute("src") ||
            el.getAttribute("data") ||
            el.getAttribute("href") ||
            "";

        // Also grab <source> children (e.g. <video><source src="..."></video>)
        if (!src) {
            var child = el.querySelector && el.querySelector("source[src]");
            if (child) src = child.getAttribute("src") || "";
        }

        var a = document.createElement("a");
        a.href = src || "#";
        a.setAttribute("data-skipped-tag", el.tagName.toLowerCase());
        a.textContent =
            "[Media skipped \u2014 " +
            el.tagName.toLowerCase() +
            (src ? ": " + src : "") +
            "]";
        a.style.cssText = [
            "display:block",
            "padding:6px 10px",
            "margin:4px 0",
            "background:#fff3cd",
            "border:1px solid #ffc107",
            "border-radius:3px",
            "color:#856404",
            "text-decoration:none",
            "word-break:break-all",
            "font-family:monospace",
            "font-size:12px",
        ].join(";");

        if (el.parentNode) {
            el.parentNode.replaceChild(a, el);
        }
    }

    function boom(root) {
        if (!root || !root.querySelectorAll) return;
        MEDIA_TAGS.forEach(function (tag) {
            var found = Array.prototype.slice.call(root.querySelectorAll(tag));
            found.forEach(makeLink);
        });
    }

    // Handle anything already in the DOM when this script runs (rare but possible
    // if the browser called us slightly late in the document lifecycle).
    if (document.documentElement) {
        boom(document);
    }


    var observer = new MutationObserver(function (mutations) {
        mutations.forEach(function (mut) {
            mut.addedNodes.forEach(function (node) {
                if (node.nodeType !== 1) return; // elements only
                var tag = node.tagName.toLowerCase();
                if (MEDIA_TAGS.indexOf(tag) !== -1) {
                    // The node itself is a media element
                    makeLink(node);
                } else {
                    boom(node);
                }
            });
        });
    });

    observer.observe(document.documentElement, {
        childList: true,
        subtree: true,
    });
})();
