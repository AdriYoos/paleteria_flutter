import { createPool } from 'mysql2/promise';

const pool = createPool({
  host: '127.0.0.1',   // o localhost
  port: 3309,
  user: 'user',
  password: 'user_password',
  database: 'Paleteria_Base_datos',
  waitForConnections: true,
  connectionLimit: 10
});

export default pool;
