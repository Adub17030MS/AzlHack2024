import React from 'react';
import { LaptopOutlined, NotificationOutlined, UserOutlined } from '@ant-design/icons';
import type { MenuProps } from 'antd';
import { Layout, Menu, theme } from 'antd';

const { Header, Content, Sider } = Layout;

const items: MenuProps['items']= [
  {
    key: `1`,
    icon: React.createElement(LaptopOutlined),
    label: `Basic Sandbox`,
    children: [
      {
        key: "sub1",
        label: `Ubuntu 22.04 VM`,
      },
    ]
  },
  {
    key: `2`,
    icon: React.createElement(LaptopOutlined),
    label: `Predefined Template Sandbox`,
    children: [
      {
        key: "sub2",
        label: `CBL-Mariner Build Environment`,
      },
      {
        key: "sub3",
        label: `Base Images Test Environment`,
      },
    ]
  },
  {
    key: `3`,
    icon: React.createElement(LaptopOutlined),
    label: `Custom Template Sandbox`,
    children: [
      {
        key: "sub4",
        label: `Custom Environment`,
      },
    ]
  },

]



const App: React.FC = () => {
  const {
    token: { colorBgContainer, borderRadiusLG },
  } = theme.useToken();
  
  console.log("asdasd")
  return (
    <Layout>
      <div
        style={{
          padding: 24,
          textAlign: 'center',
          background: colorBgContainer,
          borderRadius: borderRadiusLG,
          fontSize: 38,
        }}>
        Azure Linux Build and Test Sandbox 🧪🛠️
      </div>

      <Header style={{ display: 'flex', alignItems: 'center' }}>
        <div className="demo-logo" />
        <Menu
          theme="dark"
          mode="horizontal"
          style={{ flex: 1, minWidth: 0 }}
        />
      </Header>
      
      <Layout>
        <Sider width={300} style={{ background: colorBgContainer }}>
          <Menu
            mode="inline"
            defaultSelectedKeys={['1']}
            defaultOpenKeys={['sub1']}
            style={{ height: '100%', borderRight: 0 }}
            items={items}
          />
        </Sider>
        <Layout style={{ padding: '0 24px 24px' }}>
          <Content
            style={{
              padding: 24,
              margin: 16,
              minHeight: 280,
              background: colorBgContainer,
              borderRadius: borderRadiusLG,
            }}
          >
            Content
          </Content>
        </Layout>
      </Layout>
    </Layout>
  );
};

export default App;