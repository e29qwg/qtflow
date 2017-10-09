#include "schematicseditorwidget.h"

SchematicsEditorWidget::SchematicsEditorWidget(QWidget *parent) :
	EditorWidget(parent),
	editArea(new SchematicsEditor(this))
{
	QAction *button;
	QToolBar *toolbar = new QToolBar(this);

	button = new QAction(QPixmap(":/zoom_in.svg"), "Zoom in", toolbar);
	connect(button, SIGNAL(triggered(bool)), editArea, SLOT(zoomIn()));
	toolbar->addAction(button);

	button = new QAction(QPixmap(":/zoom_out.svg"), "Zoom out", toolbar);
	connect(button, SIGNAL(triggered(bool)), editArea, SLOT(zoomOut()));
	toolbar->addAction(button);

	addToolBar(toolbar);

	setCentralWidget(editArea);
}

void SchematicsEditorWidget::loadFile(QString path)
{
	editArea->loadFile(path);
}

QString SchematicsEditorWidget::getFilePath()
{
	return editArea->getFilePath();
}

void SchematicsEditorWidget::onContentChanged()
{
}

void SchematicsEditorWidget::saveFile()
{
}
