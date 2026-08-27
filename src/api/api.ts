import { ApiError } from '../types/chat';

export function formatApiError(error: any): ApiError {
  if (!error) {
    return {
      type: 'SERVER_ERROR',
      message: 'MSAI could not connect to the AI service. Please try again.',
    };
  }

  if (typeof error === 'string') {
    return {
      type: 'SERVER_ERROR',
      message: error,
    };
  }

  if (error.name === 'AbortError') {
    return {
      type: 'ABORTED',
      message: 'Generation was stopped by the user.',
    };
  }

  if (error.type && error.message) {
    return error as ApiError;
  }

  const msg = error.message || String(error);

  if (msg.includes('MISSING_API_KEY') || msg.includes('API key')) {
    return {
      type: 'MISSING_API_KEY',
      message: 'MSAI server API key is missing or invalid. Please configure GOOGLE_API_KEY in the environment.',
    };
  }

  if (msg.includes('quota') || msg.includes('429')) {
    return {
      type: 'QUOTA_EXCEEDED',
      message: 'Rate limit or API quota exceeded. Please wait a moment before trying again.',
    };
  }

  if (msg.includes('Failed to fetch') || msg.includes('NetworkError')) {
    return {
      type: 'NETWORK_ERROR',
      message: 'Network error. Please check your internet connection and verify the backend server is running.',
    };
  }

  return {
    type: 'SERVER_ERROR',
    message: msg || 'MSAI could not connect to the AI service. Please try again.',
  };
}
