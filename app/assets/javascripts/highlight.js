function addHighlight(targetType, relativeUrl) {
  target = (targetType == "iframe") ? document.getElementById('page-frame').contentWindow.document : document

  if ((target.getSelection().anchorNode != null) && !target.getSelection().isCollapsed) {
    var selectedText = target.getSelection().getRangeAt(0).toString();
    jQuery.ajax({type: "post", url: relativeUrl + "/courses/ajax_create_snippet/", data:{'description': selectedText}});
  }
};


function showHighlight(targetDocument, targetClass, highlightText) {
  var documentText = "";   // Full text of target document
  var textNodes = [];  // Array to store text nodes
  var textAccumLengths = [];   // Array to store accumulate character lengths for text node

  setDocumentText();
  searchHighlightText(documentText, 0);

  function setDocumentText(){
    documentText = "";
    textNodes = [];
    textAccumLengths = [];
    if (targetClass === "") {
      // For HTML
      var walker = targetDocument.createTreeWalker(targetDocument.body, NodeFilter.SHOW_ALL, null, false);
    } else {
      // For PDF with PDFjs viewer
      var walker = targetDocument.createTreeWalker(targetDocument.getElementsByClassName(targetClass)[0], NodeFilter.SHOW_ALL, null, false);
    }
    searchTextNode(walker);

    function searchTextNode(walker) {
      if (walker.firstChild()) {
        do {
          var node = walker.currentNode;
          // For element node: Recursive call for searchTextNode
          if (node.nodeType === node.ELEMENT_NODE) {
            searchTextNode(walker);
          }
          // For text node: store the element info
          else if (node.nodeType === node.TEXT_NODE) {
            var text = node.nodeValue;
            if (text) {
              documentText += text;
              textNodes.push(node);
              textAccumLengths.push(documentText.length);
            }
          }
        } while(walker.nextSibling());
        walker.parentNode();
      }
    }
  }

  function searchHighlightText(checkText, trim){
    var startNode;
    var startOffset;
    var endNode;
    var endOffset;

    var index = checkText.indexOf(highlightText);
    // When highlightText is found in checkText
    if (index >= 0){
      var textIndex =  trim + index;

      // Find the start node and offset of the highlight text
      for (var i = 0; i < textAccumLengths.length; i++){
        if (textAccumLengths[i] > textIndex){
          // Highlight text begins at textNodes[i]
          startNode = textNodes[i];
          if (i === 0){
            startOffset = textIndex;
          } else {
            startOffset = textIndex - textAccumLengths[i-1];
          }
          break;
        }
      }

      // Find the end node and offset of the highlight text
      for(var i = 0; i < textAccumLengths.length; i++){
        if(textAccumLengths[i] >= textIndex + highlightText.length){
          endNode = textNodes[i];
          if(i === 0){
            endOffset = textIndex + highlightText.length;
          }else{
            endOffset = textIndex + highlightText.length - textAccumLengths[i-1];
          }
          break;
        }
      }

      setHighlight();
      // To update textNodes and textAccumLengths (The arrays change after inserting lepo-highlight element).
      setDocumentText();
      searchHighlightText(checkText.slice(index + highlightText.length), textIndex + highlightText.length);
    }


    function setHighlight(){
      // Create range object for highlight
      var range = targetDocument.createRange();
      range.setStart(startNode, startOffset);
      range.setEnd(endNode, endOffset);

      // Divide the text node into two at the start point of range
      range.startContainer.splitText(range.startOffset);
      // Make the start point of range outside the text node
      range.setStartAfter(range.startContainer);

      if(range.endContainer.length!==range.endOffset){
        // Divide the text node into two at the end point of Range
        range.endContainer.splitText(range.endOffset);
      }
      // Make the end point of range outside the text node
      range.setEndAfter(range.endContainer);

      var currentNode = targetDocument.body;
      var currentRange= targetDocument.createRange();
      while(currentNode){
        // Set the currentRange to the position surrounding the current node
        currentRange.selectNode(currentNode);

        /*
        compareBoundaryPoints: Compare the positions of the two ranges
        Range.END_TO_START: Compare the end point of range with the start point of currentRange
        Range.START_TO_END:  Compare the start point of range with the end point of currentRange
        Range.START_TO_START: Compare start points
        range.END_TO_END: Compare end points
        If currentRange is before range, it returns -1, 0 if same position, 1 if it is after
        */
        if (currentRange.compareBoundaryPoints(Range.END_TO_START,range) >= 0){
          // When current node is located outside Range
          break;
        }
        if (currentRange.compareBoundaryPoints(Range.START_TO_END,range) <= 0){
          // When current node is located before Range
          nextSibling();
          continue;
        }
        if (currentRange.compareBoundaryPoints(Range.START_TO_START,range) >= 0 &&
        currentRange.compareBoundaryPoints(Range.END_TO_END,range) <= 0){
          // When current node is included in Range
          insertElement(currentNode);
          nextSibling();
          continue;
        }
        if (currentNode.firstChild){
          // When there is a child node, make it a current node
          currentNode = currentNode.firstChild;
        } else {
          nextSibling();
        }
      }

      function insertElement(node){
        if(node.nodeType == Node.TEXT_NODE){
          // insert lepo-highlight tag to highlight text
          var range = targetDocument.createRange();
          range.selectNode(node);
          // Change target node to lepo-highlight element
          node = targetDocument.createElement("lepo-highlight");
          range.surroundContents(node);
          setStyle(node);
        } else if(node.nodeType != Node.COMMENT_NODE){
          var clone  = node.cloneNode(true);
          var newChild = targetDocument.createElement("lepo-highlight");
          for(var i=0;i<clone.childNodes.length;i++){
            newChild.appendChild(clone.childNodes[i]);
          }
          setStyle(newChild);
          // newChild.appendChild(clone);
          while (node.firstChild) node.removeChild(node.firstChild);
          node.appendChild(newChild);
        }
      }

      function setStyle(target){
        target.style.setProperty('background-color', '#fe0', 'important');
        target.style.setProperty('display', 'inline-block', 'important');
      }

      function nextSibling(){
        do {
          if (currentNode.nextSibling){
            currentNode = currentNode.nextSibling;
            return;
          }
        } while(currentNode = currentNode.parentNode);
        // FIXME: CurrentNode will be null if it reaches the very end
      }
    }
  }
}
