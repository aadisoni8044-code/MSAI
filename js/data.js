/**
 * NV ZIP — AI Knowledge Base & Data Layer
 * Contains structured conceptual data for 12 AI technologies, sample tokenization rules,
 * vector representations, attention matrices, and simulated API payloads.
 */

window.NV_DATA = {
  // 12 Primary AI Concepts for Explorer & Modals
  concepts: {
    llm: {
      id: "llm",
      title: "Large Language Model (LLM)",
      icon: "🧠",
      category: "Foundation Architecture",
      shortDesc: "A deep neural network trained on billions of text tokens to understand and generate human language.",
      what: "An AI system built on vast deep learning parameters (e.g. 7B to 1 Trillion+) capable of understanding context, writing code, summarizing text, and answering complex questions.",
      why: "Traditional software requires rigid hand-written rules. LLMs learn statistical patterns of human thought and language directly from data.",
      input: "Text prompts, documents, or conversation history.",
      output: "Predicted token sequences forming coherent human-like answers.",
      analogy: "Like a super-librarian who has read every book in human history and can instant-synthesize answers based on underlying concepts.",
      details: [
        "LLMs use autoregressive token generation (predicting one token at a time).",
        "Trained via Self-Supervised Learning on web text, followed by RLHF (Reinforcement Learning from Human Feedback).",
        "Internal representations map words to high-dimensional geometric spaces."
      ]
    },

    gpt: {
      id: "gpt",
      title: "Generative Pre-trained Transformer (GPT)",
      icon: "🤖",
      category: "Model Architecture Family",
      shortDesc: "A specific class of autoregressive transformer models pre-trained on massive text datasets.",
      what: "Generative = creates new text; Pre-trained = trained on massive data before task fine-tuning; Transformer = uses self-attention neural blocks.",
      why: "Standardized the modern paradigm of general-purpose AI assistants that do not need task-specific re-engineering.",
      input: "Context window buffer containing user prompt and chat history.",
      output: "Sequentially predicted next tokens stream.",
      analogy: "Like a master autocomplete engine operating across millions of multidimensional concepts simultaneously.",
      details: [
        "Pioneered by OpenAI with GPT-1, GPT-2, GPT-3, GPT-4, and reasoning models.",
        "Generates text token-by-token based on probability distributions.",
        "Demonstrates emergent reasoning abilities as scale increases."
      ]
    },

    transformer: {
      id: "transformer",
      title: "Transformer Architecture",
      icon: "🔄",
      category: "Core Neural Engine",
      shortDesc: "The revolutionary neural network architecture introduced in 2017 ('Attention Is All You Need').",
      what: "A neural architecture that processes all input tokens simultaneously (in parallel) using self-attention mechanisms rather than sequentially.",
      why: "Replaced old sequential RNNs/LSTMs, allowing massive scale GPU parallel processing and capturing long-range token relationships.",
      input: "Positionally encoded token embedding vectors.",
      output: "Contextualized dense token representations.",
      analogy: "Like an orchestra where every musician hears every other musician instantly, adjusting harmony in real time.",
      details: [
        "Composed of stacked Encoder and/or Decoder blocks.",
        "Features Multi-Head Self-Attention, Feed-Forward Networks, and Residual Connections.",
        "Formed the bedrock of all modern LLMs, vision transformers, and multimodal AI."
      ]
    },

    token: {
      id: "token",
      title: "Tokens & Tokenization",
      icon: "🧩",
      category: "Data Ingestion",
      shortDesc: "The atomic units of text (words, subwords, or characters) that AI models read and write.",
      what: "A numerical chunk of text. On average, 1 token is approximately 4 characters or 0.75 words in English.",
      why: "Computers cannot directly compute on raw English strings; text must be converted into numerical vocabulary IDs.",
      input: "Raw text string ('Explain gravity').",
      output: "Array of vocabulary integer IDs ([7834, 14201]).",
      analogy: "Like LEGO bricks used to build sentences. Short words are single bricks; complex words are assembled from multiple smaller bricks.",
      details: [
        "Uses algorithms like Byte-Pair Encoding (BPE) or WordPiece.",
        "Common vocabularies range from 32,000 to 200,000 unique token IDs.",
        "Code and numbers often split into single digit or multi-character tokens."
      ]
    },

    embedding: {
      id: "embedding",
      title: "Vector Embeddings",
      icon: "🔢",
      category: "Semantic Representation",
      shortDesc: "High-dimensional numerical vectors that map semantic relationships in geometric space.",
      what: "Arrays of floating-point numbers (e.g. 1,536 or 4,096 numbers) representing the core meaning of a token or passage.",
      why: "Enables mathematical comparison of meaning. Words with similar meanings ('king' and 'queen', 'cat' and 'feline') sit close together in vector space.",
      input: "Discrete token ID.",
      output: "Dense vector array ([0.024, -0.812, 0.431, ...]).",
      analogy: "A multi-dimensional GPS coordinate for meaning. 'Apple' (fruit) is close to 'Banana', while 'Apple' (tech) aligns with 'Microsoft'.",
      details: [
        "Enables Vector Search, RAG (Retrieval-Augmented Generation), and semantic lookup.",
        "Cosine similarity measures distance between embedding vectors.",
        "Captured during embedding lookup table projection."
      ]
    },

    attention: {
      id: "attention",
      title: "Self-Attention Mechanism",
      icon: "👁️",
      category: "Contextual Weighting",
      shortDesc: "The mechanism calculating mathematical relationship weights between every pair of words in a sentence.",
      what: "Calculates Query (Q), Key (K), and Value (V) matrices to measure how much focus 'Word A' should give to 'Word B' in context.",
      why: "Resolves ambiguity. For example, in 'The bank of the river', attention connects 'bank' with 'river' instead of financial 'money'.",
      input: "Token embedding vectors.",
      output: "Weighted contextual representation vectors.",
      analogy: "Highlighters of different colors connecting related ideas across a long document.",
      details: [
        "Formula: Attention(Q, K, V) = softmax((Q * K^T) / sqrt(d_k)) * V.",
        "Multi-Head Attention runs multiple parallel attention passes.",
        "Allows infinite context cross-referencing within the context window."
      ]
    },

    neural: {
      id: "neural",
      title: "Neural Networks & Layers",
      icon: "⚡",
      category: "Deep Learning Foundations",
      shortDesc: "Interconnected layers of mathematical neurons that adjust connection weights during learning.",
      what: "Layered architectures of artificial neurons that perform matrix multiplications and non-linear activation functions.",
      why: "Acts as universal function approximators capable of learning highly complex patterns from raw data.",
      input: "Numerical vector tensors.",
      output: "Transformed activation feature maps.",
      analogy: "A complex filter grid where water flows through thousands of custom valves that adjust pressure until the right recipe emerges.",
      details: [
        "Consists of Input, Hidden, and Output layers.",
        "Trained via Backpropagation and Gradient Descent optimization.",
        "Model parameters (weights & biases) store all acquired knowledge."
      ]
    },

    context: {
      id: "context",
      title: "Context Window",
      icon: "📜",
      category: "Memory & Capacity",
      shortDesc: "The maximum number of tokens an AI model can process and hold in active memory at one time.",
      what: "The token buffer limit (e.g. 8K, 32K, 128K, or 1M+ tokens) that bounds the prompt, conversation history, and current generation.",
      why: "Determines how much document information, code, or dialog the AI can analyze without forgetting earlier details.",
      input: "Accumulated conversation tokens.",
      output: "Bounded active memory state.",
      analogy: "The size of a student's desk during an open-book exam. A bigger desk lets them keep more reference books open at once.",
      details: [
        "Longer context windows require quadratic attention memory scale (O(N^2)) unless optimized.",
        "Optimizations include FlashAttention, RingAttention, and KV-Caching.",
        "Exceeding the context window requires truncating earlier messages."
      ]
    },

    api: {
      id: "api",
      title: "AI APIs (Request / Response)",
      icon: "🌐",
      category: "Infrastructure & Integration",
      shortDesc: "Application Programming Interfaces allowing developers to connect apps to cloud AI model clusters.",
      what: "HTTP REST or WebSocket endpoints that accept structured JSON payloads and stream back generated AI responses.",
      why: "Enables embedding LLM intelligence into web apps, mobile apps, and enterprise software without hosting multi-billion parameter GPUs locally.",
      input: "HTTP POST request with prompt, temperature, and model parameters.",
      output: "JSON response object or Server-Sent Event (SSE) token stream.",
      analogy: "Like ordering food via a delivery app API — your app sends the order, the cloud kitchen cooks it, and returns the meal.",
      details: [
        "Uses standardized JSON keys like 'messages', 'temperature', and 'max_tokens'.",
        "Supports Server-Sent Events (SSE) for streaming answers character by character.",
        "Secured via API Keys and Rate Limiters."
      ]
    },

    prompt: {
      id: "prompt",
      title: "Prompts & Context Engineering",
      icon: "📝",
      category: "Interaction Design",
      shortDesc: "The input instructions, role framing, and formatting directives given to guide AI outputs.",
      what: "System messages, user instructions, and few-shot examples that shape the neural model's conditional generation probability.",
      why: "LLMs are probabilistic. Crafting clear prompts steers the model towards accurate, safe, and structured responses.",
      input: "User text, system instructions, or formatted templates.",
      output: "Conditioned generation probability state.",
      analogy: "Giving a director's script to an actor specifying tone, role, background context, and goal.",
      details: [
        "Includes System Prompts, User Prompts, and Assistant responses.",
        "Prompt engineering techniques: Chain-of-Thought (CoT), Few-Shot, and ReAct.",
        "Prevents hallucinations and enforces structured JSON formatting."
      ]
    },

    inference: {
      id: "inference",
      title: "Model Inference",
      icon: "🎯",
      category: "Execution Engine",
      shortDesc: "The operational phase where a trained AI model processes live input and generates predictions.",
      what: "Running forward passes through neural network weights to predict output tokens in production (distinct from training).",
      why: "Training happens once over months; inference happens billions of times daily when users interact with the model.",
      input: "Live user request tokens.",
      output: "Generated responses returned in milliseconds.",
      analogy: "Taking a driving test after spending years in driving school — applying learned knowledge to real-time situations.",
      details: [
        "Requires low latency and high throughput optimization.",
        "Uses quantization (FP16, INT8, INT4) to reduce VRAM requirements.",
        "Leverages KV-Caching to avoid recomputing past tokens."
      ]
    },

    gpu: {
      id: "gpu",
      title: "GPU / AI Hardware Infrastructure",
      icon: "⚡",
      category: "Hardware Foundation",
      shortDesc: "Specialized parallel hardware processors (NVIDIA H100, B200, Tensor Cores) powering AI workloads.",
      what: "Graphics Processing Units and AI Accelerators designed with thousands of small cores optimized for matrix math.",
      why: "CPUs handle sequential tasks; GPUs perform millions of parallel matrix multiplications simultaneously required by Transformers.",
      input: "Parallel mathematical tensor operations.",
      output: "High-speed matrix multiplication results.",
      analogy: "A highway with 10,000 lanes allowing thousands of cars to travel side-by-side simultaneously.",
      details: [
        "Features High Bandwidth Memory (HBM3e) reaching terabytes per second.",
        "Tensor Cores accelerate mixed-precision matrix operations.",
        "Clusters connected via high-speed NVLink interconnects."
      ]
    }
  },

  // Sample Preset Prompts and Token Breakdown Rules
  samplePrompts: {
    "Explain gravity": {
      tokens: [
        { text: "Explain", id: 7834, color: "#38bdf8" },
        { text: " gravity", id: 14201, color: "#a855f7" }
      ],
      vectors: [
        { word: "Explain", values: [0.24, -0.81, 0.43, 0.91, -0.12] },
        { word: "gravity", values: [-0.62, 0.15, 0.88, -0.34, 0.77] }
      ],
      answer: "Gravity is a fundamental force of nature that attracts objects with mass toward each other. According to Einstein's General Relativity, mass bends space-time, causing objects like planets to orbit around stars."
    },

    "Why is the sky blue?": {
      tokens: [
        { text: "Why", id: 4812, color: "#38bdf8" },
        { text: " is", id: 318, color: "#6366f1" },
        { text: " the", id: 262, color: "#a855f7" },
        { text: " sky", id: 6711, color: "#ec4899" },
        { text: " blue", id: 4172, color: "#10b981" },
        { text: "?", id: 30, color: "#f59e0b" }
      ],
      vectors: [
        { word: "Why", values: [0.11, -0.42, 0.73, 0.19, -0.52] },
        { word: "sky", values: [0.82, -0.19, 0.34, -0.88, 0.61] },
        { word: "blue", values: [-0.31, 0.94, -0.12, 0.55, -0.23] }
      ],
      answer: "The sky appears blue because of Rayleigh scattering. Earth's atmosphere scatters shorter wavelengths of sunlight (blue and violet light) in all directions far more effectively than longer wavelengths like red or yellow."
    },

    "Write a poem about neural networks": {
      tokens: [
        { text: "Write", id: 1284, color: "#38bdf8" },
        { text: " a", id: 257, color: "#6366f1" },
        { text: " poem", id: 14932, color: "#a855f7" },
        { text: " about", id: 546, color: "#ec4899" },
        { text: " neural", id: 18210, color: "#10b981" },
        { text: " networks", id: 9821, color: "#f59e0b" }
      ],
      vectors: [
        { word: "poem", values: [0.91, -0.22, 0.15, 0.67, -0.41] },
        { word: "neural", values: [0.44, 0.81, -0.63, 0.12, 0.95] },
        { word: "networks", values: [-0.25, 0.53, 0.78, -0.91, 0.38] }
      ],
      answer: "Silicon threads in darkness glow,\nWhere vector tides in silence flow.\nFrom weighted node to layer deep,\nDigital minds that never sleep."
    },

    "How do AI transformers work?": {
      tokens: [
        { text: "How", id: 2431, color: "#38bdf8" },
        { text: " do", id: 466, color: "#6366f1" },
        { text: " AI", id: 9553, color: "#a855f7" },
        { text: " transformers", id: 28412, color: "#ec4899" },
        { text: " work", id: 670, color: "#10b981" },
        { text: "?", id: 30, color: "#f59e0b" }
      ],
      vectors: [
        { word: "AI", values: [0.88, 0.72, -0.19, 0.45, 0.61] },
        { word: "transformers", values: [0.35, -0.92, 0.84, 0.11, -0.73] },
        { word: "work", values: [-0.14, 0.28, 0.51, -0.62, 0.49] }
      ],
      answer: "Transformers work by converting input tokens into vector embeddings, adding positional encodings, and passing them through stacked multi-head self-attention blocks to compute contextual relationships across all tokens in parallel."
    }
  }
};
