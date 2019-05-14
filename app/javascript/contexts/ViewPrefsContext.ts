import React from "react";
import { Selection } from "../components/dashboard/Dashboard";

export interface ViewPrefs {
  dashboardSelection?: Selection;
  dashboardTab?: string;
  notificationsTab?: number;
}

export interface UpdateViewPrefs {
  (mergeViewPrefs: ViewPrefs): void;
}

interface IViewPrefsContext {
  viewPrefs: ViewPrefs;
  updateViewPrefs: UpdateViewPrefs;
}

const ViewPrefsContext = React.createContext<IViewPrefsContext>({
  viewPrefs: {},
  updateViewPrefs: (_mergePrefs: ViewPrefs) => {}
});

export default ViewPrefsContext;