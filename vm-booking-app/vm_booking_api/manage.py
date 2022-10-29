import os
from flask_migrate import Migrate, MigrateCommand
from flask_script import Manager

from .app import db
from .app import create_app

if os.path.exists("gunicorn.envfile"):
    print("Importing environment from .env...")
    for line in open("gunicorn.envfile"):
        var = line.strip().split("=")
        if len(var) == 2:
            os.environ[var[0]] = var[1]

app = create_app()

migrate = Migrate(app, db)
manager = Manager(app)

manager.add_command("db", MigrateCommand)


def main():
    manager.run()


if __name__ == "__main__":
    main()
