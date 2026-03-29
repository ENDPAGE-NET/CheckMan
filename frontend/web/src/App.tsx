import { ConfigProvider } from 'antd'
import zhCN from 'antd/locale/zh_CN'
import { BrowserRouter, Routes, Route } from 'react-router-dom'
import theme from './theme'
import AuthGuard from './components/AuthGuard'
import AppLayout from './components/AppLayout'
import Login from './pages/Login'
import Dashboard from './pages/Dashboard'
import Employees from './pages/Employees'
import Policies from './pages/Policies'
import Records from './pages/Records'
import Admins from './pages/Admins'

export default function App() {
  return (
    <ConfigProvider theme={theme} locale={zhCN}>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route element={<AuthGuard />}>
            <Route element={<AppLayout />}>
              <Route path="/" element={<Dashboard />} />
              <Route path="/employees" element={<Employees />} />
              <Route path="/policies" element={<Policies />} />
              <Route path="/records" element={<Records />} />
              <Route path="/admins" element={<Admins />} />
            </Route>
          </Route>
        </Routes>
      </BrowserRouter>
    </ConfigProvider>
  )
}
