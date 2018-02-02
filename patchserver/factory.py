from flask import Flask
import logging
import os

from . import config
from .database import db
from .routes import api, error_handlers, jamf_pro, web_ui


def create_app():
    app = Flask(__name__)
    app.config.from_object(config)
    db.init_app(app)

    if not os.path.exists(config.DATABASE_PATH):
        with app.app_context():
            db.create_all()

    if app.config.get('SQL_LOGGING'):
        sql_logger = logging.getLogger('sqlalchemy.engine')

        for handler in app.logger.handlers:
            sql_logger.addHandler(handler)

        if app.config.get('DEBUG'):
            sql_logger.setLevel(logging.DEBUG)

    app.register_blueprint(error_handlers.blueprint)
    app.register_blueprint(web_ui.blueprint)
    app.register_blueprint(api.blueprint)
    app.register_blueprint(jamf_pro.blueprint)

    return app