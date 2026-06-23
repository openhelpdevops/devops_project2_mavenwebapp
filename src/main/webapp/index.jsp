<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OpenHelp DevOps Training</title>

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
            background: #fdf5f5;
        }

        header {
            background: linear-gradient(135deg, #b30000, #ff3333);
            color: white;
            text-align: center;
            padding: 45px 20px;
            border-bottom-left-radius: 40px;
            border-bottom-right-radius: 40px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.2);
        }

        header h1 {
            font-size: 2.8rem;
            margin-bottom: 10px;
        }

        header p {
            font-size: 1.1rem;
            opacity: 0.95;
        }

        .container {
            max-width: 1200px;
            margin: 50px auto;
            padding: 0 20px;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
            gap: 25px;
        }

        .course-card {
            background: white;
            border-radius: 20px;
            padding: 25px;
            text-align: center;
            box-shadow: 0 8px 18px rgba(0,0,0,0.10);
            transition: all 0.3s ease;
            overflow: hidden;
        }

        .course-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 12px 24px rgba(0,0,0,0.18);
        }

        .course-icon {
            width: 75px;
            height: 75px;
            margin: 0 auto 15px;
            border-radius: 50%;
            background: linear-gradient(135deg, #b30000, #ff4d4d);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 34px;
        }

        .course-title {
            font-size: 1.4rem;
            font-weight: bold;
            color: #b30000;
            margin-bottom: 12px;
        }

        .course-desc {
            color: #555;
            line-height: 1.5;
            margin-bottom: 20px;
        }

        .btn {
            display: inline-block;
            text-decoration: none;
            background: linear-gradient(135deg, #b30000, #ff3333);
            color: white;
            padding: 10px 25px;
            border-radius: 30px;
            font-weight: 600;
            transition: 0.3s;
        }

        .btn:hover {
            background: linear-gradient(135deg, #800000, #cc0000);
            transform: scale(1.05);
        }

        footer {
            text-align: center;
            margin-top: 40px;
            padding: 20px;
            color: #666;
        }
    </style>

    <!-- Font Awesome -->
    <script src="https://kit.fontawesome.com/2b5d5a9c8f.js" crossorigin="anonymous"></script>
</head>

<body>

<header>
    <h1>OpenHelp DevOps </h1>
    <p> DevOps and Cloud Technologies</p>
</header>

<div class="container">

    <div class="course-card">
        <div class="course-icon"><i class="fas fa-dharmachakra"></i></div>
        <div class="course-title">Kubernetes</div>
        <div class="course-desc">
            Master Kubernetes, Ingress, Storage, Helm, Rancher, Monitoring and Production Deployments.
        </div>
        <a href="http://openhelp.net" class="btn" target="_blank">Learn More</a>
    </div>

    <div class="course-card">
        <div class="course-icon"><i class="fab fa-aws"></i></div>
        <div class="course-title">AWS Cloud</div>
        <div class="course-desc">
            Learn EC2, VPC, IAM, S3, EKS, RDS, Load Balancers and AWS Security Best Practices.
        </div>
        <a href="http://openhelp.net" class="btn" target="_blank">Learn More</a>
    </div>

    <div class="course-card">
        <div class="course-icon"><i class="fas fa-server"></i></div>
        <div class="course-title">Terraform</div>
        <div class="course-desc">
            Automate cloud infrastructure using Infrastructure as Code across AWS, Azure and GCP.
        </div>
        <a href="http://openhelp.net" class="btn" target="_blank">Learn More</a>
    </div>

    <div class="course-card">
        <div class="course-icon"><i class="fab fa-microsoft"></i></div>
        <div class="course-title">Microsoft Azure</div>
        <div class="course-desc">
            Learn Azure Virtual Machines, AKS, Networking, Storage, Security and DevOps Services.
        </div>
        <a href="http://openhelp.net" class="btn" target="_blank">Learn More</a>
    </div>

    <div class="course-card">
        <div class="course-icon"><i class="fas fa-terminal"></i></div>
        <div class="course-title">Shell Scripting</div>
        <div class="course-desc">
            Master Linux Shell Scripting, Automation, Cron Jobs, Monitoring and System Administration.
        </div>
        <a href="http://openhelp.net" class="btn" target="_blank">Learn More</a>
    </div>

    <div class="course-card">
        <div class="course-icon"><i class="fas fa-cogs"></i></div>
        <div class="course-title">Ansible Automation</div>
        <div class="course-desc">
            Learn Ansible Playbooks, Roles, Inventories, Automation and Configuration Management.
        </div>
        <a href="http://openhelp.net" class="btn" target="_blank">Learn More</a>
    </div>

</div>

<footer>
    <h3>OpenHelp DevOps Training </h3>
    <p>DevOps | Cloud | Kubernetes | Automation | Security</p>
</footer>

</body>
</html>
