"""
Setup script for the CodeCompass package.
"""

from setuptools import setup, find_packages

setup(
    name="codecompass",
    version="0.1.0",
    description="AI-powered codebase management system",
    author="CodeCompass Team",
    author_email="info@codecompass.ai",
    packages=find_packages(),
    install_requires=[
        "litellm>=1.63.0",
        "pyyaml>=6.0",
    ],
    extras_require={
        "dev": [
            "pytest>=7.0.0",
            "pytest-cov>=4.0.0",
            "black>=23.0.0",
            "isort>=5.0.0",
        ],
    },
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.11",
    ],
    python_requires=">=3.11",
) 