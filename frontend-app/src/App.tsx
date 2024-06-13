import React, { useState } from "react";
import {
  LaptopOutlined,
  CodeSandboxOutlined,
  FormOutlined,
  ProfileOutlined,
} from "@ant-design/icons";
import type { MenuProps } from "antd";
import { Layout, Menu, theme } from "antd";
import { Button } from "antd";
import "./App.css";

const { Header, Content, Sider } = Layout;

interface VMContentProps {
  title: string;
  vmImage: string;
  description: string;
  status: string;
  setStatus: React.Dispatch<React.SetStateAction<string>>;
}
const items: MenuProps["items"] = [
  {
    key: "1",
    icon: React.createElement(CodeSandboxOutlined),
    label: "Basic Sandbox",
    children: [
      {
        key: "sub1",
        label: "Basic Environment",
      },
    ],
  },
  {
    key: "2",
    icon: React.createElement(ProfileOutlined),
    label: "Predefined Template Sandbox",
    children: [
      {
        key: "sub2",
        label: "CBL-Mariner Build Environment",
      },
      {
        key: "sub3",
        label: "Base Images Test Environment",
      },
    ],
  },
  {
    key: "3",
    icon: React.createElement(FormOutlined),
    label: "Custom Template Sandbox",
    children: [
      {
        key: "sub4",
        label: "Custom Environment",
      },
    ],
  },
];

const App: React.FC = () => {
  const [selectedKey, setSelectedKey] = useState("1");
  const [status, setStatus] = useState("Active");

  const {
    token: { colorBgContainer, borderRadiusLG },
  } = theme.useToken();

  const handleMenuClick = (e: { key: string }) => {
    setSelectedKey(e.key);
  };

  const renderVMContent = ({
    title,
    vmImage,
    description,
    status,
    setStatus,
  }: VMContentProps) => {
    const handleProvisionClick = async () => {
      // Update status to "Provisioning"
      setStatus("Provisioning");

      try {
        const response = await fetch("http://10.137.196.214:3000/", {
          method: "GET",
          headers: {
            "Content-Type": "application/json",
          },
        });

        if (!response.ok) {
          throw new Error("Network response was not ok");
        }

        const data = await response.json();
        console.log("Success:", data);

        // Update status based on response
        setStatus("Active");
      } catch (error) {
        console.error("Error:", error);

        // Revert status back to previous state on error
        setStatus("Inactive");
      }
    };

    return (
      <div className="container">
        <h1>{title}</h1>
        <div className="content">
          <p>
            <span style={{ fontWeight: "bold" }}>VM Image: </span> {vmImage}
          </p>
          <p>
            <span style={{ fontWeight: "bold" }}>Sandbox description: </span>{" "}
            {description}
          </p>
          <p>
            <span style={{ fontWeight: "bold" }}>Sandbox status: </span>{" "}
            {status}
          </p>
          <Button type="primary" onClick={handleProvisionClick}>
            Provision VM
          </Button>
          <Button type="primary" danger>
            Delete VM
          </Button>
        </div>
      </div>
    );
  };

  const renderContent = () => {
    switch (selectedKey) {
      case "sub1":
        return renderVMContent({
          title: "Basic Ubuntu VM",
          vmImage: "Ubuntu 22.04",
          description: "This is a sandbox for Ubuntu 22.04 VMs.",
          status,
          setStatus,
        });
      case "sub2":
        return renderVMContent({
          title: "CBL-Mariner Build Environment",
          vmImage: "CBL-Mariner",
          description: "This is a build environment for CBL-Mariner.",
          status,
          setStatus,
        });
      case "sub3":
        return renderVMContent({
          title: "Base Images Test Environment",
          vmImage: "Base Images",
          description: "This is a test environment for base images.",
          status,
          setStatus,
        });
      case "sub4":
        return renderVMContent({
          title: "Custom Environment",
          vmImage: "Custom Image",
          description: "This is a custom environment.",
          status,
          setStatus,
        });
      default:
        return (
          <div>Welcome to the Azure Linux Build and Test Sandbox 🧪🛠️</div>
        );
    }
  };

  return (
    <Layout>
      <div
        style={{
          padding: 24,
          textAlign: "center",
          background: colorBgContainer,
          borderRadius: borderRadiusLG,
          fontSize: 38,
        }}
      >
        Azure Linux Build and Test Sandbox 🧪🛠️
      </div>

      <Header style={{ display: "flex", alignItems: "center" }}>
        <div className="demo-logo" />
        <Menu theme="dark" mode="horizontal" style={{ flex: 1, minWidth: 0 }} />
      </Header>

      <Layout>
        <Sider width={300} style={{ background: colorBgContainer }}>
          <Menu
            mode="inline"
            defaultSelectedKeys={["1"]}
            defaultOpenKeys={["sub1"]}
            style={{ height: "100%", borderRight: 0 }}
            items={items}
            onClick={handleMenuClick}
          />
        </Sider>
        <Layout style={{ padding: "0 24px 24px" }}>
          <Content
            style={{
              padding: 24,
              margin: 16,
              minHeight: 280,
              background: colorBgContainer,
              borderRadius: borderRadiusLG,
            }}
          >
            {renderContent()}
          </Content>
        </Layout>
      </Layout>
    </Layout>
  );
};

export default App;
