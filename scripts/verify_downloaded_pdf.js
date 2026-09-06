const fs = require('fs');
const zlib = require('zlib');
const path = 'test/downloads/psa_finance_report_20260906.pdf';

if (!fs.existsSync(path)) {
  console.error('File not found:', path);
  process.exit(1);
}

const buf = fs.readFileSync(path);
console.log('PDF Length:', buf.length, 'bytes');
console.log('PDF Header:', buf.slice(0, 8).toString('ascii'));

// Extract streams
let uncompressedText = '';
let streamStart = 0;

while ((streamStart = buf.indexOf('stream\n', streamStart)) !== -1) {
  const start = streamStart + 'stream\n'.length;
  const end = buf.indexOf('endstream', start);
  if (end !== -1) {
    const chunk = buf.slice(start, end);
    try {
      const decompressed = zlib.inflateSync(chunk);
      uncompressedText += decompressed.toString('latin1') + '\n';
    } catch (e) {
      // not flate or raw
      uncompressedText += chunk.toString('latin1') + '\n';
    }
    streamStart = end + 'endstream'.length;
  } else {
    break;
  }
}

console.log('Uncompressed text length:', uncompressedText.length);
const terms = ['PSA Academy', 'Financial', 'EGP', 'Total Revenue', 'Total Expenses', 'Net Balance'];
for (const t of terms) {
  console.log(`Contains "${t}":`, uncompressedText.includes(t));
}
