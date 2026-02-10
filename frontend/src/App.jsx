import { useState } from "react";

function App() {
    const [prompt, setPrompt] = useState("");
    const [report, setReport] = useState(null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState("");

    const generateReport = async () => {
        if (!prompt.trim()) return;

        setLoading(true);
        setError("");
        setReport(null);

        try {
            const res = await fetch("http://localhost:3000/reports", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ prompt })
            });

            const data = await res.json();

            if (!res.ok) {
                throw new Error(data.error || "Something went wrong");
            }

            setReport(data);
        } catch (err) {
            setError(err.message);
        }

        setLoading(false);
    };

    return (
        <div style={styles.page}>
            <div style={styles.wrapper}>
                <h1 style={styles.title}>AI Executive Report Generator</h1>
                <p style={styles.subtitle}>
                    Transform raw business notes into structured executive intelligence.
                </p>

                <textarea
                    style={styles.textarea}
                    rows="6"
                    value={prompt}
                    onChange={(e) => setPrompt(e.target.value)}
                    placeholder="Enter revenue numbers, performance notes, risks..."
                />

                <button
                    style={{
                        ...styles.button,
                        opacity: loading ? 0.7 : 1
                    }}
                    onClick={generateReport}
                    disabled={loading}
                >
                    {loading ? "Generating..." : "Generate Report"}
                </button>

                {error && <div style={styles.error}>{error}</div>}

                {report && (
                    <div style={styles.reportCard}>
                        <Section title="Executive Summary" content={report.summary} />

                        <SectionList title="Key Insights" items={report.key_insights} />

                        <SectionList
                            title="Risks"
                            items={report.risks}
                            danger
                        />

                        <SectionList
                            title="Recommendations"
                            items={report.recommendations}
                        />
                    </div>
                )}
            </div>
        </div>
    );
}

function Section({ title, content }) {
    return (
        <div style={styles.section}>
            <h2 style={styles.sectionTitle}>{title}</h2>
            <p style={styles.paragraph}>{content}</p>
        </div>
    );
}

function SectionList({ title, items = [], danger = false }) {
    return (
        <div style={styles.section}>
            <h2 style={styles.sectionTitle}>{title}</h2>
            <ul style={styles.list}>
                {items.map((item, index) => (
                    <li
                        key={index}
                        style={{
                            ...styles.listItem,
                            color: danger ? "#ef4444" : "#d1d5db"
                        }}
                    >
                        {item}
                    </li>
                ))}
            </ul>
        </div>
    );
}

const styles = {
    page: {
        minHeight: "100vh",
        backgroundColor: "#0f172a", // deep dark blue
        display: "flex",
        justifyContent: "center",
        padding: "60px 20px",
        fontFamily: "Inter, sans-serif",
        color: "#e5e7eb"
    },
    wrapper: {
        width: "100%",
        maxWidth: "900px"
    },
    title: {
        fontSize: "32px",
        fontWeight: "600",
        marginBottom: "8px"
    },
    subtitle: {
        color: "#94a3b8",
        marginBottom: "30px"
    },
    textarea: {
        width: "100%",
        padding: "16px",
        borderRadius: "10px",
        border: "1px solid #1e293b",
        backgroundColor: "#111827",
        color: "#e5e7eb",
        fontSize: "14px",
        marginBottom: "20px",
        resize: "vertical"
    },
    button: {
        padding: "12px 24px",
        borderRadius: "8px",
        border: "none",
        background: "linear-gradient(90deg, #2563eb, #4f46e5)",
        color: "white",
        fontWeight: "500",
        cursor: "pointer",
        marginBottom: "30px"
    },
    error: {
        padding: "12px",
        backgroundColor: "#7f1d1d",
        borderRadius: "8px",
        marginBottom: "20px"
    },
    reportCard: {
        backgroundColor: "#111827",
        padding: "30px",
        borderRadius: "12px",
        border: "1px solid #1f2937"
    },
    section: {
        marginBottom: "28px"
    },
    sectionTitle: {
        fontSize: "18px",
        fontWeight: "600",
        marginBottom: "10px",
        color: "#f8fafc"
    },
    paragraph: {
        lineHeight: "1.7",
        color: "#cbd5e1"
    },
    list: {
        paddingLeft: "20px"
    },
    listItem: {
        marginBottom: "8px",
        lineHeight: "1.6"
    }
};

export default App;
