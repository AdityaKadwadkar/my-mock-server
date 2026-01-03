module.exports = {
  info: (msg, data) => console.log('[INFO]', msg, data || ''),
  error: (msg, data) => console.error('[ERROR]', msg, data || ''),
  debug: (msg, data) => console.log('[DEBUG]', msg, data || '')
};
