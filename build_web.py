import os
import shutil
import subprocess

# Paths
flutter_dir = os.path.join("UI", "safespace")
build_dir = os.path.join(flutter_dir, "build", "web")
temp_dir = os.path.join(flutter_dir, "build", "web_temp")

def main():
    print("[SafeSpace] Starting Web Build & Landing Page Restructuring...")
    
    # 1. Build the Flutter Web application with base-href /app/
    print("[SafeSpace] Step 1: Compiling Flutter Web app with base-href /app/...")
    try:
        subprocess.run(
            ["flutter", "build", "web", "--release", "--base-href", "/app/"],
            cwd=flutter_dir,
            shell=True,
            check=True
        )
    except subprocess.CalledProcessError as e:
        print(f"[-] Flutter build failed: {e}")
        return

    # 2. Restructuring built files to live in an /app/ subdirectory
    print("[SafeSpace] Step 2: Restructuring directories for Netlify deployment...")

    # Clean up any previous restructuring artifacts to prevent nesting
    if os.path.exists(temp_dir):
        shutil.rmtree(temp_dir)
    os.makedirs(temp_dir)

    # Move all built files into /app/ folder inside temp_dir
    app_dir = os.path.join(temp_dir, "app")
    os.makedirs(app_dir)

    for item in os.listdir(build_dir):
        # Skip any leftover temp directory
        if item == "web_temp":
            continue
        src = os.path.join(build_dir, item)
        dst = os.path.join(app_dir, item)
        shutil.move(src, dst)

    # Remove the nested /app/app/ folder if it exists (from previous bad runs)
    nested_app = os.path.join(app_dir, "app")
    if os.path.isdir(nested_app):
        shutil.rmtree(nested_app)

    # Remove any stale _redirects inside /app/ (Flutter doesn't generate this)
    stale_redirects = os.path.join(app_dir, "_redirects")
    if os.path.exists(stale_redirects):
        os.remove(stale_redirects)

    # Swap build_dir and temp_dir
    shutil.rmtree(build_dir)
    shutil.move(temp_dir, build_dir)

    # 3. Write the beautiful custom landing page index.html to the root of the build
    print("[SafeSpace] Step 3: Generating premium landing page index.html...")
    landing_page_html = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SafeSpace - Your AI-Powered Mental Health Sanctuary</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700;800&family=Plus+Jakarta+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-color: #070314;
            --card-bg: rgba(26, 16, 53, 0.4);
            --primary-accent: #7b3fe4;
            --primary-glow: rgba(123, 63, 228, 0.45);
            --text-white: #ffffff;
            --text-grey: #a0a5c0;
            --border-color: rgba(123, 63, 228, 0.15);
            --secondary-glow: rgba(79, 209, 165, 0.3);
            --teal-accent: #4fd1a5;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background-color: var(--bg-color);
            color: var(--text-white);
            line-height: 1.6;
            overflow-x: hidden;
            background-image: 
                radial-gradient(circle at 10% 20%, rgba(123, 63, 228, 0.15) 0%, transparent 40%),
                radial-gradient(circle at 90% 80%, rgba(79, 209, 165, 0.1) 0%, transparent 45%);
            background-attachment: fixed;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 24px;
        }

        /* Header / Navbar */
        header {
            padding: 24px 0;
            border-bottom: 1px solid var(--border-color);
            backdrop-filter: blur(12px);
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .nav-wrapper {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .logo {
            font-family: 'Outfit', sans-serif;
            font-size: 26px;
            font-weight: 800;
            background: linear-gradient(135deg, #b99eff, var(--primary-accent));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            letter-spacing: 0.5px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .logo-dot {
            width: 8px;
            height: 8px;
            background-color: var(--teal-accent);
            border-radius: 50%;
            display: inline-block;
            box-shadow: 0 0 10px var(--secondary-glow);
        }

        /* Hero Section */
        .hero {
            padding: 90px 0 60px;
            text-align: center;
            position: relative;
        }

        .hero-badge {
            display: inline-block;
            padding: 6px 16px;
            background: rgba(123, 63, 228, 0.12);
            border: 1px solid rgba(123, 63, 228, 0.3);
            border-radius: 100px;
            color: #b99eff;
            font-size: 13px;
            font-weight: 600;
            margin-bottom: 24px;
            letter-spacing: 0.5px;
            text-transform: uppercase;
        }

        .hero h1 {
            font-family: 'Outfit', sans-serif;
            font-size: 56px;
            font-weight: 800;
            line-height: 1.15;
            margin-bottom: 24px;
            background: linear-gradient(to right, #ffffff 40%, #e2d9ff 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            max-width: 900px;
            margin-left: auto;
            margin-right: auto;
        }

        .hero p {
            font-size: 18px;
            color: var(--text-grey);
            max-width: 700px;
            margin: 0 auto 40px;
            font-weight: 400;
        }

        /* Feature Cards */
        .features-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
            gap: 24px;
            margin-top: 60px;
            margin-bottom: 80px;
        }

        .feature-card {
            background: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            padding: 32px;
            transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
            text-align: left;
            position: relative;
            overflow: hidden;
            backdrop-filter: blur(8px);
        }

        .feature-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(135deg, rgba(123, 63, 228, 0.08) 0%, transparent 100%);
            opacity: 0;
            transition: opacity 0.3s ease;
        }

        .feature-card:hover {
            transform: translateY(-5px);
            border-color: rgba(123, 63, 228, 0.35);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4), 0 0 20px rgba(123, 63, 228, 0.05);
        }

        .feature-card:hover::before {
            opacity: 1;
        }

        .feature-icon {
            font-size: 32px;
            margin-bottom: 20px;
            background: linear-gradient(135deg, #b99eff, var(--primary-accent));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            display: inline-block;
        }

        .feature-card h3 {
            font-family: 'Outfit', sans-serif;
            font-size: 20px;
            font-weight: 700;
            margin-bottom: 12px;
            color: var(--text-white);
        }

        .feature-card p {
            font-size: 14px;
            color: var(--text-grey);
            line-height: 1.6;
        }

        /* Action Buttons Section */
        .cta-section {
            background: radial-gradient(circle at center, rgba(123, 63, 228, 0.15) 0%, rgba(7, 3, 20, 0) 70%);
            border-top: 1px solid var(--border-color);
            padding: 80px 0 100px;
            text-align: center;
        }

        .cta-title {
            font-family: 'Outfit', sans-serif;
            font-size: 38px;
            font-weight: 800;
            margin-bottom: 16px;
        }

        .cta-subtitle {
            color: var(--text-grey);
            font-size: 16px;
            margin-bottom: 40px;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
        }

        .buttons-wrapper {
            display: flex;
            justify-content: center;
            gap: 20px;
            flex-wrap: wrap;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 16px 36px;
            font-size: 16px;
            font-weight: 700;
            border-radius: 14px;
            text-decoration: none;
            transition: all 0.2s ease;
            cursor: pointer;
            gap: 10px;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary-accent), #9b6fff);
            color: var(--text-white);
            box-shadow: 0 10px 25px var(--primary-glow);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 15px 30px rgba(123, 63, 228, 0.6);
            background: linear-gradient(135deg, #8b52f5, #a87fff);
        }

        .btn-secondary {
            background: rgba(255, 255, 255, 0.05);
            color: var(--text-white);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .btn-secondary:hover {
            transform: translateY(-2px);
            background: rgba(255, 255, 255, 0.08);
            border-color: rgba(255, 255, 255, 0.2);
        }

        /* Footer */
        footer {
            padding: 60px 0 40px;
            border-top: 1px solid var(--border-color);
            text-align: center;
        }

        .dev-title {
            font-size: 18px;
            color: var(--teal-accent);
            margin-bottom: 20px;
            font-family: 'Outfit', sans-serif;
            font-weight: 600;
        }

        .dev-grid {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            gap: 12px;
            margin-bottom: 30px;
            max-width: 800px;
            margin-left: auto;
            margin-right: auto;
        }

        .dev-badge {
            background: rgba(123, 63, 228, 0.05);
            padding: 8px 16px;
            border-radius: 12px;
            font-size: 15px;
            border: 1px solid var(--border-color);
            color: var(--text-white);
            text-decoration: none;
            transition: all 0.3s ease;
        }

        a.dev-badge:hover {
            border-color: var(--teal-accent);
            box-shadow: 0 0 15px var(--secondary-glow);
            transform: translateY(-2px);
        }

        .copyright {
            color: rgba(160, 165, 192, 0.5);
            font-size: 14px;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .hero h1 {
                font-size: 38px;
            }
            .hero p {
                font-size: 16px;
            }
            .cta-title {
                font-size: 30px;
            }
            .buttons-wrapper {
                flex-direction: column;
                align-items: stretch;
                padding: 0 20px;
            }
            .btn {
                width: 100%;
            }
        }
    </style>
</head>
<body>

    <header>
        <div class="container nav-wrapper">
            <div class="logo">
                SafeSpace <span class="logo-dot"></span>
            </div>
        </div>
    </header>

    <main class="container">
        <section class="hero">
            <div class="hero-badge">AI-Powered Psychological Assistant</div>
            <h1>Your Intelligent Mental Wellness Sanctuary</h1>
            <p>Empowering emotional self-awareness through multi-modal AI clinical scoring (DASS-42), bilingual dialect natural language analysis, and dynamic root-cause isolation.</p>
        </section>

        <section class="features-grid">
            <div class="feature-card">
                <div class="feature-icon">📊</div>
                <h3>Clinical Psychometrics</h3>
                <p>Fully integrated DASS-42 clinical self-assessment scale evaluating separate subscale classifications for depression, anxiety, and stress levels.</p>
            </div>

            <div class="feature-card">
                <div class="feature-icon">🧠</div>
                <h3>Bilingual NLP Analysis</h3>
                <p>Advanced XLM-RoBERTa sentiment engine that automatically processes, translates, and classifies raw journal texts in English and Arabic dialects.</p>
            </div>

            <div class="feature-card">
                <div class="feature-icon">🔍</div>
                <h3>Root-Stressor Extraction</h3>
                <p>Scans assessment texts to isolate primary distress domains (Workplace, Academic, Social, Financial, Relationships) and match you with specialized exercises.</p>
            </div>

            <div class="feature-card">
                <div class="feature-icon">🛡️</div>
                <h3>Bilingual Crisis Safety Net</h3>
                <p>Deterministic realtime safety override that scans inputs for critical markers, instantly bypassing AI pipelines to deliver immediate emergency assistance.</p>
            </div>

            <div class="feature-card">
                <div class="feature-icon">🧘</div>
                <h3>Therapeutic Grounding</h3>
                <p>Features animated box breathing pacing, gamified 5-4-3-2-1 sensory exercises, meditation timers, and quick stress-relief mini-games.</p>
            </div>

            <div class="feature-card">
                <div class="feature-icon">🔄</div>
                <h3>Multi-Modal Fusion</h3>
                <p>Intelligently balances subjective survey responses and free-text entries (60/40 ratio) to construct a comprehensive wellness profile.</p>
            </div>
        </section>

        <section class="cta-section">
            <h2 class="cta-title">Begin Your Wellness Journey</h2>
            <p class="cta-subtitle">Access the platform instantly via the web application or download client packages, demonstration slides, and project documentation.</p>
            <div class="buttons-wrapper">
                <a href="/app/" class="btn btn-primary">
                    Launch Web App
                </a>
                <a href="https://drive.google.com/drive/folders/1_t6wKOu1_xH02kgAkf4ipjawEqh-AxbP?usp=sharing" target="_blank" class="btn btn-secondary">
                    Download APK & Resources
                </a>
            </div>
        </section>
    </main>

    <footer>
        <div class="container">
            <h3 class="dev-title">Developed By</h3>
            <div class="dev-grid">
                <a href="https://www.linkedin.com/in/ali-monir-sakr/" target="_blank" class="dev-badge">Ali Monir Sakr</a>
                <span class="dev-badge">Tasneem Mohamed</span>
                <span class="dev-badge">Mahmoud AboElNaga</span>
                <span class="dev-badge">Ahmad Behiry</span>
                <span class="dev-badge">Rowayda El-Bayar</span>
                <a href="https://www.linkedin.com/in/mohamed-sabry-643643265/" target="_blank" class="dev-badge">Mohamed Sabry</a>
                <span class="dev-badge">Ali Saad Ali</span>
                <span class="dev-badge">Jana Khaled Awad</span>
                <span class="dev-badge">Youssef Ehab Gomaa</span>
            </div>
            <p class="copyright">&copy; 2026 SafeSpace Project. All rights reserved.</p>
        </div>
    </footer>

</body>
</html>
"""
    with open(os.path.join(build_dir, "index.html"), "w", encoding="utf-8") as f:
        f.write(landing_page_html)

    # 4. Write Netlify _redirects file to the root build directory
    print("[SafeSpace] Step 4: Creating Netlify routing configuration (_redirects)...")
    redirects_content = """/app/*    /app/index.html   200
"""
    with open(os.path.join(build_dir, "_redirects"), "w", encoding="utf-8") as f:
        f.write(redirects_content)

    print("\n[SafeSpace] Web build successfully structured and ready for Netlify!")
    print(f"[SafeSpace] Deployment directory: {os.path.abspath(build_dir)}")
    print("[SafeSpace] Upload the folder above to Netlify to publish both your landing page and Web App!")

if __name__ == "__main__":
    main()
