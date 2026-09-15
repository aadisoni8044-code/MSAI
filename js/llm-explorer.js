/**
 * NV ZIP — Interactive LLM Explorer
 * Connects clickable nodes in the LLM architecture diagram to transparent glass info panels.
 */

class LlmExplorer {
  constructor() {
    this.diagramContainer = document.getElementById('llm-diagram');
    this.infoPanel = document.getElementById('llm-info-panel');

    this.panelIcon = document.getElementById('llm-panel-icon');
    this.panelTitle = document.getElementById('llm-panel-title');
    this.panelSubtitle = document.getElementById('llm-panel-subtitle');
    this.panelWhat = document.getElementById('llm-panel-what');
    this.panelWhy = document.getElementById('llm-panel-why');
    this.panelIn = document.getElementById('llm-panel-in');
    this.panelOut = document.getElementById('llm-panel-out');
    this.panelAnalogy = document.getElementById('llm-panel-analogy');

    this.init();
  }

  init() {
    if (!this.diagramContainer) return;

    const nodes = this.diagramContainer.querySelectorAll('.flow-node');
    nodes.forEach(node => {
      node.addEventListener('click', (e) => {
        const conceptKey = e.currentTarget.getAttribute('data-concept');
        if (conceptKey) {
          nodes.forEach(n => n.classList.remove('active'));
          e.currentTarget.classList.add('active');
          this.updatePanel(conceptKey);
        }
      });
    });

    // Default node
    this.updatePanel('user');
  }

  updatePanel(conceptKey) {
    const dataMap = {
      user: {
        icon: "👤",
        title: "User Input",
        subtitle: "The Starting Point of the Pipeline",
        what: "The person or external software application initiating a prompt request to the AI model.",
        why: "Provides the explicit instructions, background context, and query that guides the neural network's generation.",
        in: "Human thought or goal formatted as text string.",
        out: "Raw prompt string sent into tokenizer.",
        analogy: "Like a customer placing an order at a restaurant counter before the kitchen begins cooking."
      },
      prompt: {
        icon: "📝",
        title: "Prompt & Context",
        subtitle: "Structuring Context for the Model",
        what: "The combination of system instructions, user query, and historical chat messages.",
        why: "Conditions the probability distribution of the LLM so it responds in the right tone, language, and format.",
        in: "User query + System guidelines.",
        out: "Structured context string buffer.",
        analogy: "Giving a director's script to an actor specifying tone, role, and scene goal."
      },
      token: {
        icon: "🧩",
        title: "Tokenizer",
        subtitle: "Converting String to Vocabulary IDs",
        what: "A subword algorithm (like BPE) that breaks text into discrete integer vocabulary IDs.",
        why: "Neural networks are mathematical calculators that cannot directly operate on English letter characters.",
        in: "Raw text string.",
        out: "Array of integer token IDs (e.g. [7834, 14201]).",
        analogy: "Breaking a sentence into standardized LEGO bricks where each unique brick shape has a ID number."
      },
      embedding: {
        icon: "🔢",
        title: "Embedding Vectors",
        subtitle: "Mapping Meaning into High-Dimensional Space",
        what: "Lookup tables that convert each token ID into a vector of floating-point numbers (e.g. 4,096 dimensions).",
        why: "Allows mathematical calculation of word meaning and semantic similarity in geometric space.",
        in: "Discrete token integer ID.",
        out: "Dense vector array ([0.24, -0.81, 0.43, ...]).",
        analogy: "A multi-dimensional GPS coordinate for concept meaning."
      },
      transformer: {
        icon: "🤖",
        title: "Transformer Blocks",
        subtitle: "Stacked Neural Architecture",
        what: "Deep layers containing self-attention, feed-forward networks, and residual connections.",
        why: "Processes all tokens in parallel, enabling rapid GPU scaling and long-range relationship learning.",
        in: "Positionally encoded embedding vectors.",
        out: "Deep contextualized feature representations.",
        analogy: "A multi-story factory where each floor refines the product's quality and precision."
      },
      attention: {
        icon: "👁️",
        title: "Self-Attention",
        subtitle: "Contextual Weighting Engine",
        what: "A mechanism that calculates Query, Key, and Value matrices to measure token relationships.",
        why: "Resolves ambiguity by determining how strongly each word connects to every other word in context.",
        in: "Layer feature representations.",
        out: "Attention-weighted contextual vectors.",
        analogy: "Highlighters of different colors linking related terms across a long document."
      },
      neural: {
        icon: "⚡",
        title: "Neural Layers",
        subtitle: "Feed-Forward Multi-Layer Perceptron",
        what: "Dense non-linear neural networks that process and transform activation representations.",
        why: "Stores factual knowledge and complex pattern rules learned during massive pre-training.",
        in: "Attention output vectors.",
        out: "Transformed non-linear activation vectors.",
        analogy: "A complex filtration grid refining raw signals into structured output patterns."
      },
      inference: {
        icon: "🎯",
        title: "Prediction & Softmax",
        subtitle: "Probabilistic Token Selection",
        what: "The final linear layer converting neural representations into probability distributions across the vocabulary.",
        why: "Determines the single most likely (or sampled) next token continuation.",
        in: "Final layer output tensor.",
        out: "Probability scores for 100,000+ vocabulary tokens.",
        analogy: "A quiz show host selecting the highest scoring answer card from a giant deck."
      },
      output: {
        icon: "💬",
        title: "Generated Answer",
        subtitle: "Autoregressive Response Stream",
        what: "Decoding predicted token IDs back into human-readable text and displaying them to the user.",
        why: "Delivers the final helpful response back to the client application.",
        in: "Predicted token IDs.",
        out: "Formatted text answer on screen.",
        analogy: "The finished dish served to the customer at their table."
      }
    };

    const info = dataMap[conceptKey] || dataMap['user'];

    if (this.panelIcon) this.panelIcon.textContent = info.icon;
    if (this.panelTitle) this.panelTitle.textContent = info.title;
    if (this.panelSubtitle) this.panelSubtitle.textContent = info.subtitle;
    if (this.panelWhat) this.panelWhat.textContent = info.what;
    if (this.panelWhy) this.panelWhy.textContent = info.why;
    if (this.panelIn) this.panelIn.textContent = info.in;
    if (this.panelOut) this.panelOut.textContent = info.out;
    if (this.panelAnalogy) this.panelAnalogy.textContent = info.analogy;
  }
}

document.addEventListener('DOMContentLoaded', () => {
  window.llmExplorer = new LlmExplorer();
});
