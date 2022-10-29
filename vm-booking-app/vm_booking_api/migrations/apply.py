# Python script that will apply the migrations up to head
import alembic.config
import os
import sys


from flask import current_app
from vm_booking_api import create_app, db

sys.path.append(os.getcwd())

here = os.path.dirname(os.path.abspath(__file__))

if os.path.exists("gunicorn.envfile"):
    print("Importing environment from .env...")
    for line in open("gunicorn.envfile"):
        var = line.strip().split("=")
        if len(var) == 2:
            os.environ[var[0]] = var[1]

try:
    app = current_app._get_current_object()
except RuntimeError:
    app = create_app()

alembic_args = ["-c", os.path.join(here, "alembic.ini"), "upgrade", "head"]
target_metadata = db.metadata


def main():
    with app.app_context():
        alembic.config.main(argv=alembic_args)
