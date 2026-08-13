"""
feature_table_model.py

Custom QAbstractTableModel wrapping a pandas DataFrame of detected features,
facilitating table presentation and header-based sorting in a QTableView.
"""

import logging
from PyQt5.QtCore import QAbstractTableModel, Qt, QModelIndex

logger = logging.getLogger("OpenMS Analyzer.feature_table_model")

class FeatureTableModel(QAbstractTableModel):
    """
    Qt Table Model displaying data directly from a pandas DataFrame
    representing extracted molecular features.
    """
    def __init__(self, df=None):
        super().__init__()
        self._df = df if df is not None else self._empty_dataframe()

    def _empty_dataframe(self):
        import pandas as pd
        return pd.DataFrame(columns=["Feature ID", "m/z", "RT (s)", "RT (min)", "Intensity", "Charge", "Quality"])

    def setDataFrame(self, df):
        """
        Updates the model with a new pandas DataFrame and notifies the view.
        """
        self.layoutAboutToBeChanged.emit()
        self._df = df if df is not None else self._empty_dataframe()
        self.layoutChanged.emit()

    def getDataFrame(self):
        """
        Returns the current DataFrame.
        """
        return self._df

    def rowCount(self, parent=QModelIndex()):
        return self._df.shape[0]

    def columnCount(self, parent=QModelIndex()):
        return self._df.shape[1]

    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid():
            return None

        row = index.row()
        col = index.column()

        if role == Qt.DisplayRole:
            val = self._df.iloc[row, col]
            # Format floating point numbers beautifully
            if isinstance(val, float):
                if abs(val) < 0.0001 or abs(val) > 1000000:
                    return f"{val:.4e}"
                return f"{val:.4f}"
            return str(val)

        elif role == Qt.TextAlignmentRole:
            # Align numeric columns to the right, others to the left
            col_name = self._df.columns[col]
            if col_name in ["m/z", "RT (s)", "RT (min)", "Intensity", "Quality"]:
                return Qt.AlignRight | Qt.AlignVCenter
            elif col_name in ["Feature ID", "Charge"]:
                return Qt.AlignCenter
            return Qt.AlignLeft | Qt.AlignVCenter

        return None

    def headerData(self, section, orientation, role=Qt.DisplayRole):
        if role == Qt.DisplayRole:
            if orientation == Qt.Horizontal:
                return str(self._df.columns[section])
            elif orientation == Qt.Vertical:
                return str(section + 1)
        return None

    def sort(self, column, order=Qt.AscendingOrder):
        """
        Sorts the underlying DataFrame by the clicked column.
        """
        if self._df.empty:
            return

        self.layoutAboutToBeChanged.emit()
        col_name = self._df.columns[column]
        ascending = (order == Qt.AscendingOrder)

        self._df = self._df.sort_values(by=col_name, ascending=ascending).reset_index(drop=True)
        self.layoutChanged.emit()
